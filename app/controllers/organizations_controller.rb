class OrganizationsController < ApplicationController
  before_action :org_access_only

  def tags_list

    @organization = current_organization
    @middle_text = "List of all #{@organization.name} Tags"

    @tag_details = Rails.cache.fetch("#{current_organization.id}-tag_details-#{Tag.maximum(:updated_at)}-#{Tagging.maximum(:updated_at)}-#{PurchaseOrder.maximum(:updated_at)}") do 
      @organization.tag_details
    end

    Event.add_event("User","#{current_user.id}","viewed tag list")
  end

  def providers_list

    @providers = Provider.where(organization_id: params[:id].to_i)
    @organization = current_organization
    @middle_text = "List of all #{@organization.name} Suppliers"

    Event.add_event("User","#{current_user.id}","viewed supplier list")
  end

end