class UsersController < ApplicationController

  before_filter :signed_in_user
  before_filter :correct_user,   only: [:show, :edit, :update, :destroy]
  before_filter :admin_user,     only: [:destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    if @user.save
      sign_in @user
      UserMailer.welcome_email(@user).deliver
      flash[:success] = "Welcome to #{brand_name}!"
      redirect_to order_questions_path
    else
      render 'new'
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(user_params)
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
      params.require(:user).permit(:name,:email,:password,:password_confirmation)
    end

end
