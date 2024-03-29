#add examiner to user, have it be either examiner 
#need before_filters to have supporting text
#need supplier fetcher method
#need to show all, some, or none (with message) depending on return
#need update to delete or untag appropriately

class SuppliersController < ApplicationController
  include SuppliersHelper
  before_filter :admin_user, only: [:new, :create, :admin_edit, :admin_update]
  before_filter :correct_supplier_for_user, only: [:edit, :update]
  helper_method :state_sort

  def new
    @supplier = Supplier.new
    @checked_tags = Tag.tag_set(:new_supplier,:object)
    @address = Address.new
    @address.country = Geography.new
    @address.state = Geography.new
    @tags_by_group = Tag.tags_by_group
    @billing_contact = BillingContact.new
    @contract_contact = ContractContact.new
    @rfq_contact = RfqContact.new

    render layout: "old_layout"
  end

  def create
    params = clean_params

    @supplier = Supplier.new(admin_params)
    @supplier.name_for_link = Supplier.proper_name_for_link(@supplier.name)
    @supplier.create_or_update_address(address_params)
    Contact.create_or_update_contacts(@supplier,params)

    saved_ok = @supplier.save and @supplier.update_tags(params[:tag_selection])

    if saved_ok
      Crawler.delay.crawl_master([@supplier])
      redirect_to admin_edit_path(@supplier.name_for_link), notice: "Saved OK!" 
    else 
      redirect_to new_supplier_path(@supplier.name_for_link), notice: "Saving problem."
    end

  end

  def edit
    @supplier = Supplier.find(params[:id])
    @tags = @supplier.visible_tags
    @machines_quantity_hash = @supplier.machines_quantity_hash
    @point_structure = Supplier.get_in_use_point_structure

    render layout: "old_layout"
  end

  def admin_edit
    @supplier = Supplier.where("name_for_link = ?", params[:name].downcase).first
    if @supplier
      @tags = @supplier.tags
      @checked_tags = @tags
      @internal_tags = @supplier.internal_tags
      @address = @supplier.address
      @tags_by_group = Tag.tags_by_group
      @claimant = User.find_by_supplier_id(@supplier.id)
      @machines_quantity_hash = @supplier.machines_quantity_hash
      @dialogues = Dialogue.where("supplier_id = ?",@supplier.id).order("created_at desc")
      @communications = Communication.get_ordered("Supplier",@supplier.id)
      @billing_contact = @supplier.billing_contact
      @contract_contact = @supplier.contract_contact
      @rfq_contact = @supplier.rfq_contact

      render layout: "old_layout"
    else
      render template: "suppliers/profile_not_found", status: :not_found
    end
  end

  def admin_update
    params = clean_params
    @supplier = Supplier.find(params[:id])
    @supplier.assign_attributes(admin_params)
    @supplier.name_for_link = Supplier.proper_name_for_link(@supplier.name)
    @supplier.create_or_update_address(address_params)
    Contact.create_or_update_contacts(@supplier,params)

    saved_ok = @supplier.save and @supplier.update_tags(params[:tag_selection])

    if saved_ok
      note = "Saved OK!" 
    else 
      note = "Saving problem."
    end

    redirect_to admin_edit_path(@supplier.name_for_link), notice: note
  end

  def update
    params = clean_params
    @supplier = Supplier.find(params[:id])
  
    @supplier.update_attributes(supplier_params)
    
    UserMailer.email_internal_team(
      "Supplier profile edit: #{@supplier.name}",
      "They changed their suggested description, machines, services, or preferences. #{admin_edit_url(@supplier.name_for_link)}"
      )

    redirect_to edit_supplier_path(@supplier), notice: "Suggestions received! We'll be in touch once they're reviewed."
  end


  ############################################
  # supplier directory landing pages, for SEO:
  ############################################

  # top-level directory - list of countries
  def index
    # connection = ActiveRecord::Base.connection
    # @countries = connection.select_all("SELECT COUNT(*) AS count, short_name, long_name, geographies.name_for_link FROM geographies INNER JOIN addresses ON addresses.country_id=geographies.id INNER JOIN suppliers ON addresses.place_id = suppliers.id AND addresses.place_type = 'Supplier' WHERE (suppliers.profile_visible = true) GROUP BY short_name, long_name, geographies.name_for_link HAVING count(*) >= 10 ORDER BY COUNT(*) DESC").rows

    # for now, hard-code for unitedstates only
    @countries = Geography.where(name_for_link: 'unitedstates')
  end

  # list of states (in the United States; in general, first-level administrative subdivisions within country)
  def state_index
    # @country = Geography.find_by_name_for_link(params[:country])
    # for now, hard-code for unitedstates only
    @country = Geography.find_by_name_for_link('unitedstates')

    connection = ActiveRecord::Base.connection
    sql = "SELECT COUNT(*) AS count, g1.short_name, g1.long_name, g1.name_for_link FROM geographies g1 JOIN geographies g2 ON g1.geography_id=g2.id JOIN addresses ON addresses.state_id=g1.id JOIN suppliers ON addresses.place_id = suppliers.id AND addresses.place_type = 'Supplier' WHERE g2.name_for_link='#{@country.name_for_link}' AND suppliers.profile_visible = true GROUP BY g1.short_name, g1.long_name, g1.name_for_link ORDER BY g1.long_name"
    rows = connection.select_all(sql).rows

    @states_array = []
    rows.each do |row|
      # @columns=["count", "short_name", "long_name", "name_for_link"]
      long_name = row[2]
      name_for_link = row[3]
      @states_array << [ long_name, tag_index_path(@country.name_for_link, name_for_link) ]
    end
  end

  # list of tags within "state"
  def tag_index
    # @country = Geography.find_by_name_for_link(params[:country])
    # for now, hard-code for unitedstates only
    @country = Geography.find_by_name_for_link('unitedstates')
    @state = Geography.find_by_name_for_link(params[:state])

    if @state
      # Filters are currently defined for a subset of process group tags only
      @processes_array = []
      Filter.where("name like '#{@country.name_for_link}-#{@state.name_for_link}-%'").each do |f|
        process_name = Tag.find(f.has_tag_id).readable
        lookup_term = f.name.gsub("#{@country.name_for_link}-#{@state.name_for_link}-", "")
        supplier_index_path = lookup_path(@country.name_for_link, @state.name_for_link, lookup_term)
        @processes_array << [ process_name, supplier_index_path ]
      end
    else
      redirect_to state_index_path(@country.name_for_link)
    end
  end

  # list of suppliers for specified process -OR- profile for specified supplier
  def lookup
    @country = Geography.find_by_name_for_link(params[:country])
    @state = Geography.find_by_name_for_link(params[:state])
    lookup_term = params[:term].downcase
    @supplier = Supplier.find_by_name_for_link(lookup_term)
    if @supplier
      # display profile for specified supplier
      profile
    else
      if params[:state] == 'all'
        @filter = Filter.find_by_name("#{params[:country]}-#{lookup_term}")
      else
        @filter = Filter.find_by_name("#{params[:country]}-#{params[:state]}-#{lookup_term}")
      end

      if @filter
        # display list of suppliers for specified process
        supplier_index
      else
        # no matching supplier or process found for given lookup term
        # assume lookup_term was for a supplier, display "not found"
        profile
      end
    end
  end

  # list of supplier profiles within geography for given process
  def supplier_index
    if @filter
      @location_phrase = @filter.geography.long_name

      tag = Tag.find(@filter.has_tag_id)
      @tags_short = tag.readable
      @tags_long = tag.note

      @visibles, @supplier_count = Supplier.visible_profiles_sorted(@filter)
      @adjacencies = @filter.adjacencies
    end

    render "supplier_index", layout: "old_layout"
  end

  def profile
    # toggle if certain parts of the profile are visible
    @machines_toggle = true
    @reviews_toggle = true
    @photos_toggle = false

    current_user.nil? ? @user_id = 0 : @user_id = current_user.id

    if allowed_to_see?(@supplier)
      @tags = @supplier.visible_tags if @supplier
      @machines_quantity_hash = @supplier.machines_quantity_hash
      @num_machines = @machines_quantity_hash.sum{|k,v| v}
      @num_reviews = @supplier.visible_reviews.count

      @meta = ""
      @meta += "Tags for #{@supplier.name} include " + andlist(@tags.take(3).map{ |t| "\"#{t.readable}\""}) + ". " if @tags.present?
      profile_factors = andlist(meta_for_supplier(@supplier))
      @meta += "The #{@supplier.name} profile has " + andlist(meta_for_supplier(@supplier)) + ". " if profile_factors.present?
      @meta = @meta.present? ? @meta : "#{@supplier.name} - Supplier profile"
      render "profile", layout: "old_layout"
    else
      render "profile_not_found", status: :not_found
    end
  end

  private

    def admin_params
      params.permit(:name, :name_for_link, :url_main, :url_materials, :description, \
                    :email, :phone, :source, :profile_visible, :claimed, \
                    :suggested_description, :suggested_machines, :suggested_preferences, \
                    :internally_hidden_preferences, :suggested_services, :suggested_address, \
                    :suggested_url_main, :points, :next_contact_date, :next_contact_content
                    )
    end

    def supplier_params
      params.permit(:suggested_description, :suggested_machines, :suggested_preferences, \
                    :suggested_services, :suggested_address, :url_main, :email, :phone
                    )
    end

    def address_params
      params.permit(:country, :state, :zip)
    end

  def meta_for_supplier(supplier)
    #http://stackoverflow.com/questions/6806473/rails-3-is-there-a-way-to-use-pluralize-inside-a-model-seems-to-only-work-in
    potential_includes = []
    potential_includes << "a custom description" if supplier.description.present?
    potential_includes << "machines listed" if supplier.owners.present?
    potential_includes << "reviews from previous buyers" if supplier.reviews.present?
    return potential_includes
  end

end