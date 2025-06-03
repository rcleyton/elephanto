# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  resources :decks do
    resources :flashcards, only: %i[ new create show ] do
      member do
        post :review
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
