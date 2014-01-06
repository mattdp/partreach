# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  phone            :string(255)
#  email            :string(255)
#  method           :string(255)
#  notes            :text
#  type             :string(255)
#  contactable_id   :integer
#  contactable_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  first_name       :string(255)
#  last_name        :string(255)
#  title            :string(255)
#  company          :string(255)
#

class LeadContact < Contact

end
