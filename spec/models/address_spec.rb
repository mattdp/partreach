# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  street     :string(255)
#  city       :string(255)
#  zip        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  place_id   :integer
#  place_type :string(255)
#  notes      :text
#  country_id :integer
#  state_id   :integer
#

require 'spec_helper'

describe "Address" do

  before(:all) do
    @some_country = FactoryGirl.create :geography, level: 'country'
    @some_state = FactoryGirl.create :geography, level: 'state'
    @unknown_country = FactoryGirl.create :country_unknown
    @unknown_state = FactoryGirl.create :state_unknown
  end

  it "creates a valid address with default parameters" do
    supplier = FactoryGirl.build(:supplier, address: nil)
    supplier.create_or_update_address()
    expect(supplier.address.country).to eq @unknown_country
    expect(supplier.address.state ).to eq @unknown_state
  end

  it "creates a valid address with supplied parameters" do
    supplier = FactoryGirl.build(:supplier, address: nil)
    supplier.create_or_update_address(city: 'Timbuktu', country: @some_country.short_name, state: @some_state.short_name)
    expect(supplier.address.city).to eq 'Timbuktu'
    expect(supplier.address.country).to eq @some_country
    expect(supplier.address.state ).to eq @some_state
  end

  it "updates an existing address with supplied parameters" do
    supplier = FactoryGirl.build(:supplier)
    supplier.address.update(city: 'Los Angeles')
    supplier.create_or_update_address(city: 'Timbuktu', country: @some_country.short_name, state: @some_state.short_name)
    expect(supplier.address.city).to eq 'Timbuktu'
    expect(supplier.address.country).to eq @some_country
    expect(supplier.address.state ).to eq @some_state
  end

  it "does not update/nullify fields for which parameters are not supplied" do
    supplier = FactoryGirl.build(:supplier)
    supplier.address.update(city: 'Los Angeles')
    original_country = supplier.address.country
    supplier.create_or_update_address(zip: '12345', state: @some_state.short_name)
    expect(supplier.address.city).to eq 'Los Angeles'
    expect(supplier.address.country).to eq original_country
    expect(supplier.address.zip ).to eq '12345'
    expect(supplier.address.state ).to eq @some_state
  end

end
