# == Schema Information
#
# Table name: communications
#
#  id                   :integer          not null, primary key
#  means_of_interaction :string(255)
#  interaction_title    :string(255)
#  notes                :text
#  created_at           :datetime
#  updated_at           :datetime
#  user_id              :integer
#  communicator_id      :integer
#  communicator_type    :string(255)
#

class Communication < ActiveRecord::Base

  belongs_to :communicator, polymorphic: true
  belongs_to :supplier
  belongs_to :user

  validates :communicator_id, presence: true
  validates :communicator_type, presence: true
  validates :means_of_interaction, presence: true

  def self.get_ordered(model,id)
    Communication.where(communicator_id: id).where(communicator_type: model).order(id: :desc)
  end

  def self.has_communication?(model,interaction_title)
    if model and comms = model.communications and comms.present?
      return comms.any?{|c| c.interaction_title == interaction_title}
    end
  end

end
