Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'welcome/index'
  root 'welcome#index'
  devise_for :users, controllers: { sessions: "users/sessions",
                                    registrations: "users/registrations",
                                    passwords:  "users/passwords" }
  get 'questions/:id(:integer)',   to: 'questions#show'
  resources :question_categories, only: :destroy
  resources :questions,           only: [:index, :destroy]
  resources :answers,             only: [:create, :update, :destroy]
end
