class PurchaseOrdersController < ApplicationController
  before_filter :admin_user
  
  def index
    @users = User.all #get rid of this once PO method is done
  end

end