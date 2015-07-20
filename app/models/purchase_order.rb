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

  belongs_to :provider, touch: true
  has_one :comment
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings

  #does this purchase order want feedback? does not say if the user is emailable
  def wants_feedback?(issue_date_padding = 7, wait_for_parts_to_arrive = 7)
    return false if self.dont_request_feedback #has no special flags
    return false if (self.created_at + 31.days < Date.today) #less than a month old
    return false if (self.issue_date.present? and (self.issue_date + issue_date_padding > Date.today)) #has had enough time to be delivered
    comment = self.comment
    return false unless (comment.present? and comment.untouched?) #comment is untouched
    events = Event.where(happening: "said contact me later", target_model: "Comment", target_model_id: comment.id)
    if events.present?
      events.each do |event|
        return false if (event.created_at + wait_for_parts_to_arrive.days >= Date.today)
      end
    end
    return true
  end

  #return {user: {purchase_order: , followup_number:, emailable_date: }}
  def self.users_and_email_suggestions
    answer = {}

    id_shells = Comment.joins(:purchase_order).select('DISTINCT (comments.user_id) AS user_id')
    users = id_shells.map{|shell| User.find(shell.user_id)}
    
    users.each do |user|
      purchase_order = nil
      followup_number = nil
      emailable_date = user.emailable_date

      if emailable_date <= Date.today
        comments = Comment.where(user_id: user.id)
          .where(comment_type: "purchase_order")
          .order(:created_at)

        comments.each do |comment|
          next unless comment.purchase_order.present?
          po = comment.purchase_order
          if po.wants_feedback? and !user.dont_ask_for_feedback.include?(po.provider.name)
            purchase_order = po
            #this followup is the number of these events that exist + 1
            followup_number = Event.where(happening: "sent_reminder_email")
              .where(model: "User")
              .where(model_id: user.id)
              .where(target_model: "Comment")
              .where(target_model_id: comment.id).count + 1
            break
          end
        end
      end

      answer[user] = {
        emailable_date: emailable_date,
        purchase_order: purchase_order,
        followup_number: followup_number
      }
    end

    return answer
  end

end
