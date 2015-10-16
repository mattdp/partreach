class OrganizationsController < ApplicationController
  before_action :org_access_only
  before_filter :admin_user, except: [:tags_list, :providers_list]

  def tags_list

    @organization = current_organization
    @purchase_order_titles = @organization.has_any_pos?
    @middle_text = "List of all #{@organization.name} Tags"

    #tagging touches tag; po and comment touch provider
    cache_maxes = "#{Tag.where(organization_id: @organization.id).maximum(:updated_at)}"
    cache_maxes += "-#{@organization.last_provider_update}"
    cache_maxes += "-#{@purchase_order_titles}"

    @tag_details = Rails.cache.fetch("#{current_organization.id}-tag_details-#{cache_maxes}") do 
      if @purchase_order_titles
        @organization.tag_details(:purchase_order)
      else
        @organization.tag_details(:comment)
      end
    end

    Event.add_event("User","#{current_user.id}","viewed tag list")
  end

  def providers_list

    @organization = current_organization
    @providers = Provider.where(organization_id: current_organization.id)
    @middle_text = "List of all #{@organization.name} Suppliers"
    @purchase_order_titles = @organization.has_any_pos?

    Event.add_event("User","#{current_user.id}","viewed supplier list")
  end

  def searches
    @organization = Organization.find(params[:id])
    single_search_events = Event.where(model: "User", happening: "searched one item")
    @searches = []
    single_search_events.each do |event| 
      user = User.find(event.model_id)
      next unless user.team.organization_id == @organization.id
      hash = {}
      hash[:user_name] = user.lead.lead_contact.full_name_untrusted
      hash[:event_created_at] = event.created_at
      searched_model = event.target_model.constantize.find(event.target_model_id)
      hash[:searched] = searched_model.name
      @searches << hash
    end
    multiple_search_events = Event.where()
  end

  def show
    @organization = Organization.find(params[:id])
    @user_behaviors = @organization.user_behaviors
  end

end