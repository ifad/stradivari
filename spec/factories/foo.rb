# This will guess the Foo class
FactoryGirl.define do
  factory :foo, :class => Foo do
    sequence(:id){|n| n}
    name "name field value"
    text_field "text field value"
    string_field "string field value"
    sequence(:boolean_field){|n| n%2}
    created_at "Mon, 29 Sep 2014 12:07:45 +0000"
    updated_at "Mon, 29 Sep 2014 12:07:45 +0000"
  end
end