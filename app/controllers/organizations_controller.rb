class OrganizationsController < ApplicationController
  before_action :org_access_only

  def tags_list
    @tags = Tag.where(organization_id: params[:id].to_i)
  end

  def providers_list
    @providers = Provider.where(organization_id: params[:id].to_i)
  end

end