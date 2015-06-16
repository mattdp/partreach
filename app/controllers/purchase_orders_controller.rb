class PurchaseOrdersController < ApplicationController
  before_filter :admin_user
  
  def index
    @structure = PurchaseOrder.users_and_email_suggestions
  end

end