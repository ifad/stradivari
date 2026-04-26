# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
    # The Hawk model adapter only loads when the optional Hawk gem is present;
    # the Rails3 filter adapter targets a Rails major outside the supported matrix.
    add_filter 'lib/stradivari/filter/model/hawk.rb'
    add_filter 'lib/stradivari/table/model/hawk.rb'
    add_filter 'lib/stradivari/filter/model/rails3.rb'
    add_filter 'lib/stradivari/version.rb'

    track_files 'lib/**/*.rb'

    minimum_coverage 90 if ENV['COVERAGE_MINIMUM'] != 'false'
  end
end

require 'combustion'

Combustion.path = 'spec/internal'
Combustion.initialize! :active_record, :action_controller, :action_view, :action_mailer do
  config.action_controller.allow_forgery_protection = false
end

require 'rspec/rails'
require 'webmock/rspec'
require 'database_cleaner/active_record'
require 'nokogiri'
require 'csv'
require 'roo'

require 'support/view_context'
require 'support/factories'
require 'support/xlsx_helpers'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = false

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.include ViewContext
  config.include Factories
  config.include XlsxHelpers

  DatabaseCleaner.strategy = :transaction

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
