# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  model      :string(255)
#  happening  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  model_id   :integer
#

require 'spec_helper'

describe Event do
  pending "add some examples to (or delete) #{__FILE__}"
end
