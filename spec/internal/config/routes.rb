Rails.application.routes.draw do
  resources :widgets, only: %i[index show]
  resources :categories, only: %i[index]
end
