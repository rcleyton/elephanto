# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "landing#index"

  get  "/sign_up", to: "users#new"
  post "/sign_up", to: "users#create"

  get "terms",   to: "landing/pages#terms"
  get "privacy", to: "landing/pages#privacy"

  resource  :session
  resources :passwords, param: :token
  resources :profiles, only: %i[ new create show edit update ]

  resources :decks do
    resources :flashcards, only: %i[ show new create edit update destroy] do
      member do
        post :review
      end
    end
    
    get :reviewed_completed, to: "flashcards#reviewed_completed"

    member do
      get :review, to: "flashcards#start_review"
    end
  end

  resource :confirmation, only: %i[ show create ]

  get "up" => "rails/health#show", as: :rails_health_check
end
