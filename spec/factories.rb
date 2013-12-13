FactoryGirl.define do
  factory :user do
    sequence(:name)   { |n| "Personis#{n}" }
    sequence(:email)  { |n| "personis#{n}@example.com" }   
    password              "foobar"
    password_confirmation "foobar"
    supplier_id           nil
    admin                 false
  end

  factory :order do |o|
    association :user
  	sequence(:quantity) { |n| n + 50 }
    material_message    "Made of iron and wine"
    drawing_units       "in."
    sequence(:deadline) { |n| "#{n} o'clock"}
  end

  factory :supplier do |s|
    sequence(:name)   { |n| "Supplier#{n}" }
    sequence(:name_for_link) { |n| "supplier#{n}" }
    profile_visible        true
    s.after(:build) do |supplier|
      supplier.address ||= FactoryGirl.build(:address, :place_id => supplier.id)
      supplier.billing_contact ||= FactoryGirl.build(:billing_contact, :contactable_id => supplier.id)
      supplier.contract_contact ||= FactoryGirl.build(:contract_contact, :contactable_id => supplier.id)
      supplier.rfq_contact ||= FactoryGirl.build(:rfq_contact, :contactable_id => supplier.id)
    end
  end

  factory :tag do |t|
    sequence(:name)           { |n| "Tag#{n}" }
    sequence(:name_for_link)  { |n| "tag#{n}" }
    sequence(:readable)       { |n| "Readable#{n}" }
    family                    "generic"
    exclusive                 false
  end

  #this is bad - need to replace has_tag with a real tag
  factory :filter do |f|
    association :geography
    has_tag     1
    sequence(:name)   { |n| "Filter#{n}" }
  end

  factory :address do |a|
    place_type          "Supplier"
    a.after(:build) do |address|
      address.country ||= FactoryGirl.build(:geography, level: "country")
      address.state ||= FactoryGirl.build(:geography, level: "state")
    end
  end

  factory :geography do |g|
    sequence(:name_for_link) { |n| "nfl#{n}"}
  end

  factory :billing_contact do |c|
  end
  factory :contract_contact do |c|
  end
  factory :rfq_contact do |c|
  end    

end