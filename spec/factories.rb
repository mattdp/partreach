FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person#{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password              "foobar"
    password_confirmation "foobar"
    admin false
  end

  factory :order do |o|
    association :user
  	sequence(:quantity) { |n| n + 50 }
  end

end