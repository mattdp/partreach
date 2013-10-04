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
  end

  factory :supplier do |s|
    sequence(:name)   { |n| "Supplier#{n}" }
    sequence(:name_for_link) { |n| "supplier#{n}" }
    s.after(:build) do |supplier|
      supplier.address ||= FactoryGirl.build(:address, :place_id => supplier.id)
    end
  end

  factory :address do |a|
    country             "Outer Haven"
    place_type          "Supplier"
  end

  factory :tag do |t|
    sequence(:name)     { |n| "Tag#{n}" }
    sequence(:readable) { |n| "Readable#{n}" }
    family              "generic"
    exclusive           false
  end

end