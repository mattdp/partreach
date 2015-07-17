class OrganizationsController < ApplicationController
  before_action :org_access_only

  def tags_list
    @organization = current_organization
    @middle_text = "List of every #{@organization.name} Supplier Tag (may take a while to load all rows)"

    @tag_details = Rails.cache.fetch("#{current_organization.id}-tag_details-#{Tag.maximum(:updated_at)}-#{Tagging.maximum(:updated_at)}-#{PurchaseOrder.maximum(:updated_at)}") do 
      @org.tag_details
    end
  end

  def providers_list
    @providers = Provider.where(organization_id: params[:id].to_i)
    @organization = current_organization
    @middle_text = "List of every #{@organization.name} Supplier (may take a while to load all rows)"
  end

end