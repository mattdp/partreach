#add examiner to user, have it be either examiner 
#need before_filters to have supporting text
#need supplier fetcher method
#need to show all, some, or none (with message) depending on return
#need update to delete or untag appropriately

class ExaminationsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user

  def index
  	@questionables = Supplier.up_to_ten_datadumps
  end

  def update
  end

end