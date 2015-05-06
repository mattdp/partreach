module SessionsHelper

  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    cookies.permanent[:allow_staging_access] = 'true'
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
    session[:return_to] = nil
  end

  def signed_in_user
    store_location
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def allow_staging_access
    # okay to proceed in environments other than staging
    return unless Rails.env.staging?
    # allow signed_in user to proceed in staging
    return if signed_in?
    # allow non-signed-in user to proceed in staging, if allow_staging_access cookie is set to true
    return if cookies[:allow_staging_access] == 'true'
    # otherwise, require signin
    redirect_to signin_url
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def admin_user
    redirect_to(root_path) unless (current_user && current_user.admin?)
  end

  def org_access_only
    store_location
    redirect_to signin_url unless org_access_allowed?
  end

  def org_access_allowed?
    current_user.try(:in_organization?) || current_user.try(:admin?)
  end

  def current_organization
    @current_user.organization if @current_user
  end

  def examiner_user
    redirect_to(root_path) unless (current_user && (current_user.admin? || current_user.examiner?))
  end

  def correct_supplier_for_user
    redirect_to(root_path) unless (current_user && (current_user.admin? || (current_user.supplier_id && current_user.supplier_id == params[:id].to_i)))
  end

  def brand_name
    return "SupplyBetter"
  end

  def base_url
    return "http://www.supplybetter.com" if Rails.env.production?
    return "http://quiet-waters-6381.herokuapp.com" if Rails.env.staging?
    return "localhost:3000" if Rails.env.development?
    return "http://www.supplybetter.com"
  end

end
