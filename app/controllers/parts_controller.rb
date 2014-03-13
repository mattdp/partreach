class PartsController < ApplicationController

  def create_with_external
    p params
    puts params['filename']
    puts "creating part with #{params['order_group_id']}, #{params['filename']}"
    part = Part.create({order_group_id: params['order_group_id'], name: params['filename']})
    external = External.create({url: params['url'], \
        consumer_id: part.id, consumer_type: "Part" }) if part
    render json: true
  end

end
