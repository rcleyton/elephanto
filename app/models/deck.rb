# typed: false
# frozen_string_literal: true

class Deck < ApplicationRecord
    has_many :flashcards, dependent: :destroy

    belongs_to :user

    validates :name, presence: true
    validates :description, presence: true
end
