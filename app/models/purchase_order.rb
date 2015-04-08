class PurchaseOrder < ActiveRecord::Base

  belongs_to :provider
  has_one :comment
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings

end
