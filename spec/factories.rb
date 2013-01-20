FactoryGirl.define do
  factory :user do
    name     "Greg Maddux"
    email    "maddux@spam.mdp.net"
    password "foobar"
    password_confirmation "foobar"
  end
end