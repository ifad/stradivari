Rails.application.routes.draw do
  resources :foos
  get 'welcome/index', 'welcome/posts', 'welcome/tree', 'welcome/details'
end
