ENV['RAILS_ENV'] ||= 'test'

require 'support/init'
require 'support/routes'
require 'rspec/rails'
require 'csv'
require 'haml'
require 'stradivari'
require 'support/data'
require 'support/file_helpers'

include Stradivari::Spec::Data

Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  config.include Stradivari::Spec::FileHelpers

  config.order = "random"

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.infer_base_class_for_anonymous_controllers = false

  config.before(:suite) do
    setup_dummy_schema
    create_dummy_data
  end
end