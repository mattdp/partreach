# == Schema Information
#
# Table name: purchase_orders
#
#  id                      :integer          not null, primary key
#  provider_id             :integer
#  price                   :decimal(10, 2)
#  quantity                :integer
#  created_at              :datetime
#  updated_at              :datetime
#  description             :text
#  project_name            :string(255)
#  issue_date              :date
#  id_in_purchasing_system :integer
#  dont_request_feedback   :boolean
#

class PurchaseOrder < ActiveRecord::Base

  belongs_to :provider
  has_one :comment
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings

  #does this purchase order want feedback? does not say if the user is emailable
  def wants_feedback?(issue_date_padding = 7)
    return false if self.dont_request_feedback
    return false if (self.issue_date.present? and (self.issue_date + issue_date_padding >= Date.today))
    comment = self.comment
    return false unless (comment.present? and comment.untouched?)
    return true
  end

end
