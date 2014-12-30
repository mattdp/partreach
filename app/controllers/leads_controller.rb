class LeadsController < ApplicationController
  before_filter :admin_user, only: [:new, :edit, :index, :update]

  def new
    @lead = Lead.new
    @lead_contact = LeadContact.new
    @text_field_setup = text_field_setup
  end

  def create
    # Took this out because #create_or_update_lead was being used many places different ways.  Need
    # to make it uniform if it's going to be used multiple places.
    @lead = Lead.create_or_update_lead({
      lead: {source: "email_collector"},
      lead_contact: {email: params[:email_field]}
    })
    next_step = params[:next_step_field]

    flash[:notice] = "Thanks! We'll keep you posted."
    redirect_to next_step
  end

  def blog_create
    @lead = Lead.create_or_update_lead({
      lead: {source: "blog_email_collector"},
      lead_contact: {email: params[:email_field]}
    })
    
    redirect_to "/blog"
  end

  def admin_create
    @lead = Lead.create(lead_params)
    @lead.lead_contact = LeadContact.create(lead_contact_params)

    redirect_to edit_lead_path(@lead), notice: "Lead update attempted."
  end

  def index
    @leads = Lead.sorted(true)
  end

  def edit
    @lead = Lead.find(params[:id])
    @lead_contact = @lead.lead_contact
    @user = @lead.user
    @communications = Communication.get_ordered("Lead",@lead.id)
    @text_field_setup = text_field_setup
  end

  def update
    @lead = Lead.find(params[:id])
    @lead.update_attributes(lead_params)
    @lead_contact = @lead.lead_contact
    @lead_contact.update_attributes(lead_contact_params)

    redirect_to edit_lead_path(@lead), notice: "Lead update attempted."
  end

  private

    def text_field_setup
      return {
      "@lead_contact" => [:phone,:email,:name,:first_name,:last_name,:company,:title,:linkedin_url],
      "@lead" => [:source,:next_contactor,:next_contact_content]
      }
    end

    def lead_params
      params.permit(:source,:next_contact_date,:next_contact_content,:next_contactor,:priority,:how_found_us)
    end

    def lead_contact_params
      params.permit(:phone,:email,:first_name,:last_name,:name,:company,:title,:linkedin_url,:notes)
    end

end