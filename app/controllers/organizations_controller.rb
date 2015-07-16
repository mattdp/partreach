class OrganizationsController < ApplicationController
  before_action :org_access_only

  def tags_list
    @org = current_organization
    @tag_details = @org.tag_details    
  end

  def providers_list
    @providers = Provider.where(organization_id: params[:id].to_i)
    @org = current_organization
  end

end