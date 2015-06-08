class UsersController < ApplicationController

  before_filter :signed_in_user
  before_filter :correct_user,   only: [:show, :edit, :update, :destroy]
  before_filter :admin_user,     only: [:destroy]

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @lead_contact = @user.lead.lead_contact

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @lead_contact = @user.lead.lead_contact

    render layout: "old_layout"
  end

  # create omitted - no direct way as of now

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    @lead_contact = @user.lead.lead_contact

    saved_ok = @lead_contact.update_attributes(lead_contact_params)
    saved_ok = (saved_ok and @user.update_attributes(user_params)) if params[:password].present?

    respond_to do |format|
      if saved_ok
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless (current_user?(@user) || @user.admin)
    end

    def user_params
      params.permit(:password,:password_confirmation)
    end

    def lead_contact_params
      params.permit(:name,:email)
    end

end
