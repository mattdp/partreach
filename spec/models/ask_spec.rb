# == Schema Information
#
# Table name: asks
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  user_id     :integer
#  request     :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  real        :boolean
#

require 'spec_helper'

describe Ask do
  pending "add some examples to (or delete) #{__FILE__}"
end
