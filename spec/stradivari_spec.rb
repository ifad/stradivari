p "testing on Rails " << Rails::VERSION::STRING

RSpec.describe "stradivari" do
  context 'index page with foos data' do
    it "renders index page in html format" do
      visit "/welcome/index"
      save_result("welcome_index.html", page.source)
      expect(page.source).to eq(load_result "welcome_index.html"), "expected same source"
    end

    it "renders index page in csv format" do
      visit "/welcome/index.csv"
      save_result("welcome_index.csv", page.source)
      expect(page.source).to eq(load_result "welcome_index.csv"), "expected same source"
    end
  end

  context 'details page with foo data' do
    it "renders details in html" do
      visit "/welcome/details"
      save_result("details.html", page.source)
      expect(page.source).to eq(load_result "details.html"), "expected same source"
    end
  end

  context 'post page with posts data' do
    it "renders posts page in csv format" do
      visit "/welcome/posts.csv"
      save_result("posts.csv", page.source)
      expect(page.source).to eq(load_result "posts.csv"), "expected same source"
    end

    it "renders posts page in html format" do
      visit "/welcome/posts"
      save_result("posts.html", page.source)
      expect(page.source).to eq(load_result "posts.html"), "expected same source"
    end
  end

  context 'tree with no data' do
    it "renders tree in html" do
      visit "/welcome/tree"
      save_result("tree.html", page.source)
      expect(page.source).to eq(load_result "tree.html"), "expected same source"
    end
  end
end

