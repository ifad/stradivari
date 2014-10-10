#it's a sad world and i had to do this
Rails.application.routes.draw do
  resources :foos
  get 'anonymous/index','anonymous/posts'
end