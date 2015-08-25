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

  #for dropdowns, what means no project - should be in one place
  def self.none_selected
    "None selected"
  end

end
