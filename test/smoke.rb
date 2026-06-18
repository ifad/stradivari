# Boot a minimal Rails 8.1 app and exercise stradivari's load-bearing paths on
# Ruby 4 / Rails 8.1 / Haml 6 / Ransack 4. No DB server needed (sqlite memory).
# Exits non-zero on the first failure. This is the gem's first automated check.
$stdout.sync = true
require 'logger'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'active_record'
require 'haml'      # installed (gemspec dep); stradivari no longer auto-requires it
require 'stradivari'

failures = []
def check(label, &blk)
  yield
  puts "[ok] #{label}"
rescue => e
  puts "[FAIL] #{label}: #{e.class}: #{e.message}"
  puts e.backtrace.first(5).map { |l| "      #{l}" }
  $failed = true
end

class SmokeApp < Rails::Application
  config.eager_load = false
  config.secret_key_base = 'x' * 40
  config.logger = Logger.new(IO::NULL)
  config.hosts.clear if config.respond_to?(:hosts)
end
Rails.application.initialize!

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :widgets do |t|
    t.string  :name
    t.boolean :active
  end
end

class Widget < ActiveRecord::Base
  def self.ransackable_attributes(_ = nil) = %w[name active]
  def self.ransackable_associations(_ = nil) = []
end
Widget.create!(name: 'Alpha', active: true)
Widget.create!(name: 'Beta',  active: false)

puts "stack: ruby #{RUBY_VERSION} / Rails #{Rails::VERSION::STRING} / " \
     "AR #{ActiveRecord::VERSION::STRING} / Haml #{Haml::VERSION} / " \
     "Ransack #{Ransack::VERSION rescue '?'}"

# 1. Filter dispatch must resolve on Rails 8 (was: raised "Unsupported AR version")
check "filter dispatch resolves on Rails 8 (Widget.stradivari_filter present)" do
  raise "stradivari_filter missing" unless Widget.respond_to?(:stradivari_filter)
  raise "stradivari_all missing"    unless Widget.respond_to?(:stradivari_all)
end

# 2. Ransack 4 path through stradivari_filter
check "stradivari_filter runs a ransack query (Ransack 4)" do
  rel = Widget.stradivari_filter({ 'name_cont' => 'lph' })
  raise "expected 1 row, got #{rel.to_a.size}" unless rel.to_a.map(&:name) == %w[Alpha]
end

# View context with the gem's helpers (engine injects StradivariHelper).
view = ActionView::Base.with_empty_template_cache.new(
  ActionController::Base.view_paths, {}, ActionController::Base.new
)
view.extend(StradivariHelper)

# 3. Haml-6 compat shim (haml_tag / haml_concat / capture_haml)
check "haml_tag builds a tag via the Haml-6 shim" do
  out = view.haml_tag(:span, 'hi', class: 'badge')
  # haml_tag appends to the buffer and returns nil; capture to inspect
  html = view.capture { view.haml_tag(:span, 'hi', class: 'badge') }
  raise "bad tag: #{html.inspect}" unless html.include?('<span class="badge">hi</span>')
end

# 4. table_for end-to-end (uses haml_tag throughout the generator)
check "table_for renders an HTML table" do
  html = view.table_for(Widget.all) do
    column :name
    column :active
  end.to_s
  raise "no <table>: #{html[0, 200].inspect}" unless html.include?('<table')
  raise "missing data" unless html.include?('Alpha')
end

# 5. tabs_for (heavy capture_haml usage)
check "tabs_for renders" do
  html = view.tabs_for do
    tab('One', 'one', 'one', counter: false) { 'first body' }
    tab('Two', 'two', 'two', counter: false) { 'second body' }
  end.to_s
  raise "empty tabs" if html.strip.empty?
end

if $failed
  puts "\nSMOKE FAILED"
  exit 1
else
  puts "\nSMOKE OK — stradivari loads + renders on Ruby 4.0.5 / Rails 8.1 / Haml 6 / Ransack 4"
end
