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

end
