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

    factory :examiner_user do
      examiner  true
    end

    factory :team_user do
      team
    end
  end

  factory :team do
    sequence(:name)   { |n| "name#{n}" }
    organization
  end

  factory :organization do
    sequence(:name)   { |n| "name#{n}" }
    sequence(:people_are_called)   { |n| "people_are_called#{n}" }
  end

  factory :lead do |l|
    lead_contact
  end

  factory :provider do
    sequence(:name)   { |n| "name#{n}" }
    sequence(:name_for_link)   { |n| "name_for_link#{n}" }
    organization
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

  factory :part do
    sequence(:name)   { |n| "Part #{n}" }
    quantity          1
    material          "ABS"
    order_group
  end

  factory :order_group do
    sequence(:name)   { |n| "Order Group #{n}" }
    after(:build) do |order_group|
      order_group.parts << create_list(:part, 1, order_group: order_group)
    end
    order
  end

  factory :order do
    material_message    "Made of iron and wine"
    sequence(:deadline) { |n| "#{n} o'clock"}
    units               "mm."
    user
    after(:build) do |order|
      order.order_groups << create_list(:order_group, 1, order: order)
    end
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

  factory :tag_group do |tg|
    sequence(:group_name)  { |n| "tag_group#{n}" }
  end

  factory :tag do |t|
    sequence(:name)           { |n| "Tag#{n}" }
    sequence(:name_for_link)  { |n| "tag#{n}" }
    sequence(:readable)       { |n| "Readable#{n}" }
    exclusive                 false
    tag_group
  end

  factory :tag_relationship_type do |trt|
  end

  #has_tag always must be provided
  factory :filter do |f|
    sequence(:name)   { |n| "Filter#{n}" }
    association :geography, level: "state"
  end

  factory :geography do |g|
    sequence(:name_for_link) { |n| "nfl#{n}"}
    sequence(:long_name) { |n| "ln#{n}" }
    sequence(:short_name) { |n| "sn#{n}" }

    factory :country_unknown do
      level 'country'
      short_name 'unknown'
      long_name 'Unknown'
      name_for_link Geography.proper_name_for_link('country_unknown')
    end

    factory :state_unknown do
      level 'state'
      short_name 'unknown'
      long_name 'Unknown'
      name_for_link Geography.proper_name_for_link('state_unknown')
    end

    factory :united_states do
      level 'country'
      name_for_link 'unitedstates'
      long_name 'United States'
      short_name 'US'
    end
  end

  factory :address do |a|
    country { create(:geography, level: "country") }
    state { create(:geography, level: "state") }
  end

  factory :review do |r|
  end

  factory :web_search_result do |wsr|
  end

  factory :search_exclusion do |se|
  end
end