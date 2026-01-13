# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  constraints(lambda { |req| req.subdomain.blank? }) do
    root to: "landing#index"

    controller "landing/pages" do
      get "terms"
      get "privacy"
    end
  end

  constraints(lambda { |req| req.subdomain == "app" || req.host == "app.localhost" }) do
    root to: "home#redirect", as: :app_root

    get  "admin",    to: "admin#index"
    get  "/sign_up", to: "users#new"
    post "/sign_up", to: "users#create"

    resource  :session
    resources :passwords, param: :token
    resources :profiles, only: %i[new create show edit update]

    resource :settings, only: [ :show ] do
      patch   :update_password
      patch   :rigor_factor
      delete  :delete_account
      patch   :daily_limit

      collection do
        delete :remove_deck
      end
    end

    get "/statistics", to: "statistics#stats"

    resources :decks do
      resources :flashcards, only: %i[show new create edit update destroy] do
        member do
          post :review
        end
      end

      member do
        get :review,             to: "flashcards#start_review"
        get :reviewed_completed, to: "flashcards#reviewed_completed"
      end
    end

    resource :confirmation, only: %i[show new create]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
end
