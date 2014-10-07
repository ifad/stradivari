ENV['RAILS_ENV'] ||= 'test'

#require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'dummy/init'
require 'rspec/rails'
require 'capybara/rspec'
require 'factory_girl_rails'
require 'haml'
require 'stradivari'

#include StradivariHelper

Rails.backtrace_cleaner.remove_silencers!

def setup_dummy_schema
  ActiveRecord::Base.class_eval do
    connection.instance_eval do
      create_table :users, :force => true do |t|
        t.string :name
        t.string :email
      end
      create_table :posts, :force => true do |t|
        t.string  :title, :body
        t.integer :user_id
      end
      create_table :foos, :force => true do |t|
        t.string  :name, :text_field, :string_field
        t.datetime :created_at, :updated_at
        t.boolean :boolean_field
      end
    end
  end
end

def load_result(name)
  @result = ''
  File.new(File.dirname(__FILE__) + "/expected_results/#{name}").each_line { |l| @result += l }
  @result
end

def save_result(name, result)
  File.open(File.dirname(__FILE__) + "/actual_results/#{name}", 'w') { |file| file.write(result) }
end

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.before(:suite) do
    setup_dummy_schema
  end
end



