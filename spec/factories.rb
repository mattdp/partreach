FactoryGirl.define do
  factory :user do
    sequence(:name)   { |n| "Personis#{n}" }
    sequence(:email)  { |n| "personis#{n}@example.com"}   
    password              "foobar"
    password_confirmation "foobar"
  end

  factory :order do |o|
    association :user
  	sequence(:quantity) { |n| n + 50 }
    material_message    "Made of iron and wine"
    drawing_units       "in."
  end

  factory :supplier do |s|
    sequence(:name)   { |n| "Supplier#{n}"}
    category          "default"
  end

end