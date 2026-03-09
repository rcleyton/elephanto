# typed: false
# frozen_string_literal: true

class Deck < ApplicationRecord
  has_many :flashcards, dependent: :destroy
  has_many :review_sessions, dependent: :destroy

  has_one_attached :cover_image

  belongs_to :user

  before_create :assign_random_cover_color

  validates :name, presence: true
  validates :description, presence: true
  validates :tag, presence: true

  scope :recent,    -> { order(created_at: :desc).limit(2) }
  scope :favorites, -> { where(favorite: true) }
  scope :archived,  -> { where(archived: true) }

  def toggle_favorite!
    update!(favorite: !favorite)
  end

  private

  def assign_random_cover_color
    self.cover_color ||= self.class.random_gradient
  end

  def self.random_gradient
    gradients = [
      "linear-gradient(135deg, #6366F1, #A855F7)",
      "linear-gradient(135deg, #06B6D4, #3B82F6)",
      "linear-gradient(135deg, #F59E0B, #EF4444)",
      "linear-gradient(135deg, #10B981, #22C55E)",
      "linear-gradient(135deg, #EC4899, #8B5CF6)",
      "linear-gradient(135deg, #0EA5E9, #22C55E)"
    ]

    gradients.sample
  end
end
