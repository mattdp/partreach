module SessionsHelper

	def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
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
  end

  def signed_in_user
    store_location
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def examiner_user
    redirect_to(root_path) unless current_user.admin? or current_user.examiner?
  end

  def correct_supplier_for_user
    redirect_to(root_path) unless current_user.admin? or (current_user.supplier_id and current_user.supplier_id == params[:id].to_i)
  end

  def brand_name
    return "SupplyBetter"
  end

  def track(category,action,label)
    if Rails.env.production? and (current_user.nil? or !current_user.admin)
      Analytics.track(
        event: action,
        properties: { category: category, 
                      label: label}
      )
    end
  end

end
