FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :order do
  	sequence(:quantity) { |n| n + 50 }
  	sequence(:user_id) { |n| n % 2 }
  end

end