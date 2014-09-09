class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter :set_csrf_cookie_for_ng
  include SessionsHelper

#http://stackoverflow.com/questions/128450/best-practices-for-reusing-code-between-controllers-in-ruby-on-rails/130821#130821

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  #http://stackoverflow.com/questions/1183506/make-blank-params-nil
  def clean_params
    @clean_params ||= HashWithIndifferentAccess.new.merge blank_to_nil( params )
  end

  def blank_to_nil(hash)
    hash.inject({}){|h,(k,v)|
      h.merge(
        k => case v
        when Hash
          blank_to_nil v
        when Array
          v.map{|e| e.is_a?( Hash ) ? blank_to_nil(e) : e}
        else 
          v == "" ? nil : v
        end
      )
    }
  end

  def andlist(clauses)
    case clauses.length
    when 0
      return ""
    when 1
      return "#{clauses[0]}"
    when 2
      return "#{clauses[0]} and #{clauses[1]}"
    else
      clauses[clauses.length-1] = "and " + clauses[clauses.length-1]
      return clauses.join ", "
    end
  end

  def allowed_to_see?(model)
    return false if model.nil?
    return true if model.profile_visible
    return false if current_user.nil?
    return true if current_user.admin?
    (return true if current_user.supplier_id == supplier.id) if model.class.to_s == "Supplier"
    return false
  end

  protected

    def verified_request?
      super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
    end

end
