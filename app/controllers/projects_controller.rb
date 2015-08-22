class ProjectsController < ApplicationController
  before_action :org_access_only

  def new
    @organization = current_organization
    @project = Project.new
    Event.add_event("User","#{current_user.id}","loaded new project page from unknown source")
  end

  def create
    @project = Project.new
    create_or_update_project
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    create_or_update_project
  end

  def create_or_update_project
    @project.id.present? ? http_verb = "update" : http_verb = "create"
    @project.assign_attributes(project_params) #returns nil
    if @project.save
      Event.add_event("User","#{current_user.id}","#{http_verb}d a project","Project","#{@project.id}")
      #redirect_to teams_profile_path(@provider.name_for_link), note: "Saved OK!" 
    else
      Event.add_event("User","#{current_user.id}","attempted project #{http_verb} - ERROR")
      #redirect_to teams_index_path, note: "Saving problem."
    end
  end

  private

    def project_params
      params.permit(:name,:description)
    end
end