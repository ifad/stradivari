ENV['RAILS_ENV'] ||= 'test'

require 'dummy/init'
require 'rspec/rails'
require 'capybara/rspec'
require 'haml'
require 'stradivari'
require 'support/data'
require 'support/file_helpers'

include StradiTest::Data

Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include StradiTest::FileHelpers

  config.order = "random"

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do 
    setup_dummy_schema
    create_dummy_data
  end
end