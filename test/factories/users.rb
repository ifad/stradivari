# This will guess the User class
FactoryGirl.define do
  factory :user, :class => User do
    name "pippo"
    email "pippo@pippo.com"
  end
end