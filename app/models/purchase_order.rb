class PurchaseOrder < ActiveRecord::Base

  belongs_to :provider
  has_one :comment

end
