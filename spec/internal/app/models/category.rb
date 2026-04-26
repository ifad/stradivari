class Category < ActiveRecord::Base
  has_many :widgets, dependent: :nullify
end
