Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'items#show'

  resources :items, only:[:index, :new, :create, :show]
  resources :users

  resources :item_detail, only: [:index]
end
