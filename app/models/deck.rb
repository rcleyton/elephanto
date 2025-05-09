class Deck < ApplicationRecord
    has_many :flashcards, dependent: :destroy
    validates :name, presence: true
    validates :description, presence: true
end
