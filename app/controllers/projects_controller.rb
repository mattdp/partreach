class ProjectsController < ApplicationController
  before_action :org_access_only

  def edit
    @project = Project.find(params[:id])
    @inbound_link = nil
    @inbound_link = request.headers['HTTP_REFERER'] if (request.present? and request.headers.present?)
  end

  def update
    @project = Project.find(params[:id])
    create_or_update_project
  end

  def create_or_update_project
    @project.id.present? ? http_verb = "update" : http_verb = "create"
    @project.assign_attributes(project_params) #returns nil
    @project.organization_id = current_organization.id
    if @project.save
      Event.add_event("User","#{current_user.id}","#{http_verb}d a project","Project","#{@project.id}")
      success_notice = "Project updated!"
      if params[:inbound_link].present?
        redirect_to params[:inbound_link], notice: success_notice
      else
        redirect_to teams_index_path, notice: success_notice
      end
    else
      Event.add_event("User","#{current_user.id}","attempted project #{http_verb} - ERROR")
      redirect_to new_project_path, notice: "Error saving project. Please contact SupplyBetter support, we'll get this figured out!" 
    end
  end

  private

    def project_params
      params.permit(:name,:description)
    end
end