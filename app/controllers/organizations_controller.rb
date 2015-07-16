class OrganizationsController < ApplicationController
  before_action :org_access_only

  def tags_list
    @org = current_organization

    @tag_details = Rails.cache.fetch("#{current_organization.id}-tag_details-#{Tag.maximum(:updated_at)}-#{Tagging.maximum(:updated_at)}-#{PurchaseOrder.maximum(:updated_at)}") do 
      @org.tag_details
    end
  end

  def providers_list
    @providers = Provider.where(organization_id: params[:id].to_i)
    @org = current_organization
  end

end