require "bundler/setup"
require "minitest/autorun"
require "nokogiri"
require "rails"
require "factory_girl"
require "dummy/init"
require "rails/test_help"
require "fileutils"
require "haml"
require "haml/template"
require "stradivari"

include StradivariHelper

FactoryGirl.find_definitions

if defined?(I18n.enforce_available_locales)
  I18n.enforce_available_locales = true
end

ActionController::Base.logger = Logger.new(nil)

Haml::Template.options[:ugly]   = false
Haml::Template.options[:format] = :xhtml

module Declarative
  def test(name, &block)
    define_method("test #{name}", &block)
  end
end

class Haml::TestCase < MiniTest::Spec
  
  include FactoryGirl::Syntax::Methods

  extend Declarative

  def render(text, options = {}, base = nil, &block)
    scope  = options.delete(:scope)  || Object.new
    locals = options.delete(:locals) || {}
    engine = Haml::Engine.new(text, options)
    return engine.to_html(base) if base
    engine.to_html(scope, locals, &block)
  end

  def assert_warning(message)
    the_real_stderr, $stderr = $stderr, StringIO.new
    yield

    if message.is_a?(Regexp)
      assert_match message, $stderr.string.strip
    else
      assert_equal message.strip, $stderr.string.strip
    end
  ensure
    $stderr = the_real_stderr
  end

  def silence_warnings(&block)
    Haml::Util.silence_warnings(&block)
  end

  # Rails hidden_fields behavior changed here: https://github.com/rails/rails/commit/7a085dac2
  # and again here: https://github.com/rails/rails/commit/89ff1f82f0
  def rails_form_opener
    if Rails.version < '4.1.0'
      '<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>'
    elsif Rails.version < '4.2.0'
      '<div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /></div>'
    else
      '<input name="utf8" type="hidden" value="&#x2713;" />'
    end
  end

  def assert_raises_message(klass, message)
    yield
  rescue Exception => e
    assert_instance_of(klass, e)
    assert_equal(message, e.message)
  else
    flunk "Expected exception #{klass}, none raised"
  end

  def self.error(*args)
    Haml::Error.message(*args)
  end
  
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
        end
      end
    end
  end

  def load_result(name)
    @result = ''
    File.new(File.dirname(__FILE__) + "/expected_results/#{name}.xhtml").each_line { |l| @result += l }
    @result
  end

  def save_result(name, result)
    File.open(File.dirname(__FILE__) + "/actual_results/#{name}.xhtml", 'w') { |file| file.write(result) }
  end

  def assert_renders_correctly(name, &render_method)
    old_options = Haml::Template.options.dup
    Haml::Template.options[:escape_html] = false

    render_method ||= proc { |n| @base.render(:file => n) }
    
    silence_warnings do
        result = load_result(name)
        save_result(name, render_method[name])
        result.split("\n").zip(render_method[name].split("\n")).each_with_index do |pair, line|
        message = "template: #{name}\nline:     #{line}"
        assert_equal(pair.first, pair.last, message)
      end
    end
  rescue ActionView::Template::Error => e
    if e.message =~ /Can't run [\w:]+ filter; required (one of|file) ((?:'\w+'(?: or )?)+)(, but none were found| not found)/
      puts "\nCouldn't require #{$2}; skipping a test."
    else
      raise e
    end
  ensure
    Haml::Template.options = old_options
  end


end

module Haml::Filters::Test
  include Haml::Filters::Base
  def render(text)
    "TESTING HAHAHAHA!"
  end
end

module Haml::Helpers
  def test_partial(name, locals = {})
    Haml::Engine.new(File.read(File.join(StradivariTest::TEMPLATE_PATH, "_#{name}.haml"))).render(self, locals)
  end
end

class Egocentic
  def method_missing(*args)
    self
  end
end

class DummyController
  attr_accessor :logger
  def initialize
    @logger = Egocentic.new
  end

  def self.controller_path
    ''
  end

  def controller_path
    ''
  end
end
