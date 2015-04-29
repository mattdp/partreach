# == Schema Information
#
# Table name: purchase_orders
#
#  id           :integer          not null, primary key
#  provider_id  :integer
#  price        :decimal(10, 2)
#  quantity     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  description  :text
#  project_name :string(255)
#

class PurchaseOrder < ActiveRecord::Base

  belongs_to :provider
  has_one :comment
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings

end
