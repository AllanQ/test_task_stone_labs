Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'welcome/index'
  root 'welcome#index'
  devise_for :users, controllers: { sessions: "users/sessions",
                                    registrations: "users/registrations",
                                    passwords:  "users/passwords" }
  resources :question_categories, only: [:index, :show, :destroy]
  resources :questions, only: [:index, :show, :destroy]
  resources :answers,   only: [:create, :update, :destroy]
end
