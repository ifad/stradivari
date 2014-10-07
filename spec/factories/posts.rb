# This will guess the Post class
FactoryGirl.define do
  factory :post, :class => Post do
    sequence :title do |n|
      "post title #{n}"
    end
    body "post body"
  end
end