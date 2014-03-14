# == Schema Information
#
# Table name: combos
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  tag_id      :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe "Combo" do
	it "should prevent duplicate supplier/tag pairs"
end
