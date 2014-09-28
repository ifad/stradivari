require 'test_helper'
require 'action_pack/version'

p "Testing Stradivari with Rails #{Rails::VERSION::STRING}"

class StradivariTest < Haml::TestCase
  TEMPLATE_PATH = File.join(File.dirname(__FILE__), "templates")
  TEMPLATES = %w{stradivari_base}

  def setup
    FactoryGirl.reload
    setup_dummy_schema
    @base = create_base
    @foos = build_list(:foo, 25)
    @user = build(:user)
    @user.posts = build_list(:post, 20, user: @user)
    p @user.posts
  end

  def render(text, options = {})
    return @base.render(:inline => text, :type => :haml) if options == :action_view
    options = options.merge(:format => :html5)
    super(text, options, @base)
  end

  def create_base
    base = ActionView::Base.new(TEMPLATE_PATH)
    base.instance_variable_set('@template', base)
    def base.protect_against_forgery?; false; end
    base
  end

  # TEMPLATES.each do |template|
  #   define_method "test_template_should_render_correctly [template: #{template}]" do
  #     assert_renders_correctly template
  #   end
  # end

  def test_base_template
    @base.instance_variable_set("@foos", @foos)
    assert_renders_correctly "stradivari_base"
  end

  def test_posts_template
    @base.instance_variable_set("@posts", @user.posts)
    assert_renders_correctly "stradivari_posts"
  end

  # def test_user_template
  #   @base.instance_variable_set("@user", @user)
  #   assert_renders_correctly "stradivari_user"
  # end

  def test_html_with_no_data
    assert_equal(<<HTML, render(<<HAML, :action_view))
<div class='no-data alert alert-warning'>There is no data.</div>
HTML
= table_for @no_data do
  - column :id
HAML
  end
end
