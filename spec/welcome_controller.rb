require 'csv'

class WelcomeController < ApplicationController
  def index
  	@foos = Foo.all.page(1)
  end

  def posts
  	@posts = Post.all.page(1)
  end
end
