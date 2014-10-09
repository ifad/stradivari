class ApplicationController < ActionController::Base; end

#it's a sad world and i had to do this
Rails.application.routes.draw do
  resources :foos
  get 'anonymous/index','anonymous/posts'
end

p "testing with Rails " << Rails::VERSION::STRING

RSpec.describe ApplicationController, :type => :controller do

  render_views

  # Generating Anonymous controller for testing
  controller do
    append_view_path(Dir.pwd + "/spec/templates")
    respond_to :html, :xlsx, :csv

    def index
      @foos = Foo.all.page(1)
      respond_with (@foos) do |format|
        format.html  {render :template => "index.html.haml"}
        format.xlsx  {render :template => "index.xlsx.haml"}
        format.csv   {render :template => "index.csv.haml"}
      end
    end

    def tree
      render :template => "tree.html.haml"
    end

    def details
      @foo = Foo.first
      respond_with (@foo) do |format|
        format.html  {render :template => "details.html.haml"}
      end
    end

    def posts
      @posts = Post.all.page(1)
      respond_with (@posts) do |format|
        format.html  {render :template => "posts.html.haml"}
        format.csv   {render :template => "posts.csv.haml"}
      end
    end
  end

  before do
    @routes.draw do
      get "index" => "anonymous#index"
      get "details" => "anonymous#details"
      get "tree" => "anonymous#tree"
      get "posts" => "anonymous#posts"
      get "foo" => "anonymous#foo"
    end
  end

  context 'index page with foos data' do
    it "renders index page in html format" do
      get :index, :format => :html
      save_result("index.html", response.body)
      expect(response.body).to eq (load_result "index.html")
    end

    it "renders index page in csv format" do
      get :index, :format => :csv
      save_result("index.csv", response.body)
      expect(response.body).to eq(load_result "index.csv")
    end
  end

  context 'details page with foo data' do
    it "renders details in html" do
      get :details
      save_result("details.html", response.body)
      expect(response.body).to eq(load_result "details.html")
    end
  end

  context 'post page with posts data' do
    it "renders posts page in csv format" do
      get :posts, :format => :csv
      save_result("posts.csv", response.body)
      expect(response.body).to eq(load_result "posts.csv")
    end

    it "renders posts page in html format" do
      get :posts, :format => :html
      save_result("posts.html", response.body)
      expect(response.body).to eq(load_result "posts.html")
    end
  end

  context 'tree with no data' do
    it "renders tree in html" do
      get :tree
      save_result("tree.html", response.body)
      expect(response.body).to eq(load_result "tree.html")
    end
  end

end