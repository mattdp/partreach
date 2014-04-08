FactoryGirl.define do

  factory :user do |u|
    password              "foobar"
    password_confirmation "foobar"
    supplier_id           nil
    admin                 false
    lead

    factory :admin_user do
      admin   true
    end
  end

  factory :lead do |l|
    lead_contact
  end

  factory :contact, class: 'Contact' do |c|
    sequence(:name)   { |n| "name#{n}" }
    sequence(:email)   { |n| "email#{n}@fake.spam.com" }
  end
  factory :lead_contact, parent: :contact, class: "LeadContact" do |c|  
  end
  factory :billing_contact, parent: :contact, class: "BillingContact" do |c|  
  end
  factory :contract_contact, parent: :contact, class: "ContractContact" do |c|  
  end
  factory :rfq_contact, parent: :contact, class: "RfqContact" do |c|  
  end 

  factory :order do |o|
    material_message    "Made of iron and wine"
    sequence(:deadline) { |n| "#{n} o'clock"}
    user
  end

  factory :supplier do |s|
    sequence(:name)           { |n| "Supplier#{n}" }
    sequence(:name_for_link)  { |n| "supplier#{n}" }
    profile_visible           true
    address
    billing_contact
    contract_contact
    rfq_contact
  end

  factory :tag do |t|
    sequence(:name)           { |n| "Tag#{n}" }
    sequence(:name_for_link)  { |n| "tag#{n}" }
    sequence(:readable)       { |n| "Readable#{n}" }
    family                    "generic"
    exclusive                 false
  end

  #has_tag always must be provided
  factory :filter do |f|
    sequence(:name)   { |n| "Filter#{n}" }
    geography
  end

  factory :geography do |g|
    level     "state"
    sequence(:name_for_link) { |n| "nfl#{n}"}
  end

  factory :address do |a|
    country { create(:geography, level: "country") }
    state { create(:geography, level: "state") }
  end

  factory :review do |r|
  end

end