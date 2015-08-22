# == Schema Information
#
# Table name: projects
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  description     :text
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer
#

class Project < ActiveRecord::Base

  has_many :comments
  belongs_to :organization

end
