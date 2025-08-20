# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "landing#index"

  get  "/sign_up", to: "users#new"
  post "/sign_up", to: "users#create"

  resource  :session
  resources :passwords, param: :token
  resources :profiles, only: %i[ new create show edit update ]

  resources :decks do
    resources :flashcards, only: %i[ show new create edit update destroy] do
      member do
        post :review
      end
    end

    member do
      get :review, to: "flashcards#start_review"
    end
  end

  resource :confirmation, only: [ :show ]

  get "up" => "rails/health#show", as: :rails_health_check
end
