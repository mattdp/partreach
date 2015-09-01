class OrganizationsController < ApplicationController
  before_action :org_access_only

  def tags_list

    @organization = current_organization
    @middle_text = "List of all #{@organization.name} Tags"

    #tagging touches tag; po and comment touch provider
    cache_maxes = "#{Tag.where(organization_id: @organization.id).maximum(:updated_at)}"
    cache_maxes += "-#{@organization.last_provider_update}"

    @tag_details = Rails.cache.fetch("#{current_organization.id}-tag_details-#{cache_maxes}") do 
      @organization.tag_details
    end

    Event.add_event("User","#{current_user.id}","viewed tag list")
  end

  def providers_list

    @organization = current_organization
    @providers = Provider.where(organization_id: current_organization.id)
    @middle_text = "List of all #{@organization.name} Suppliers"

    Event.add_event("User","#{current_user.id}","viewed supplier list")
  end

end