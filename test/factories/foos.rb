# This will guess the Foo class
FactoryGirl.define do
  factory :foo, :class => Foo do
    sequence :id do |n|
    	n
    end
    name "pippo"
    text_field "text_field"
    string_field "string_field"
  end
end