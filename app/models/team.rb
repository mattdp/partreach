# == Schema Information
#
# Table name: teams
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class Team < ActiveRecord::Base

  has_many :users
  belongs_to :organization

  def create_user!(email, first_name, last_name=nil, password="changemeplease")
    User.transaction do
      user = User.create!(team: self, password: password, password_confirmation: password)
      lead = Lead.create!(user: user)
      name = first_name
      name += " #{last_name}" if last_name
      LeadContact.create!(contactable: lead, name: name, email: email, first_name: first_name, last_name: last_name)
    end
  end

  def create_demo_user!(email,first_name,last_name,password="showme")
    user = self.create_user!(email,first_name,last_name,password)
  end

  #put all demo users on this team. important to have since demo reset sometimes, throwing away users
  def create_demo_users!
    Team.demo_users.each do |email,other|
      user = self.create_demo_user!(email,other[:first_name],other[:last_name])
      puts "User creation failed for #{email}" if user.nil?
    end
  end

  #meant to be frequently updated
  def self.demo_users
    users = {}

    users["demo@demo.com"] = {first_name: "Demo", last_name: "User"}

    return users
  end

end
