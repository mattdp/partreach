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
    @project.organization_id = current_organization.id
    if @project.save
      Event.add_event("User","#{current_user.id}","#{http_verb}d a project","Project","#{@project.id}")
      if http_verb == "create"
        # to do: send to a sensible place
        redirect_to edit_project_path(@project.id), notice: "Saved OK!" 
      else
        redirect_to edit_project_path, notice: "Updated OK!"
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