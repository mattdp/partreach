FactoryGirl.define do
  factory :user do
    sequence(:name)   { |n| "Person#{n}" }
    sequence(:email)  { |n| "person_#{n}@example.com"}   
    password              "foobar"
    password_confirmation "foobar"
  end

  factory :order do |o|
    association :user
  	sequence(:quantity) { |n| n + 50 }
    material_message    "Made of iron and wine"
  end

end