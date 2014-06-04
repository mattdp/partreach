class PartsController < ApplicationController

  def create_with_external
  	Part.create_with_external(params['order_group_id'], params['filename'], params['url'])
  	
	render nothing: true
  end

end
