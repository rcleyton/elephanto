# typed: false
# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user

  has_one_attached :avatar

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :username,   presence: true, uniqueness: true
  validates :bio,        presence: true
  validates :learning_speed, numericality: { greater_than: 0.5, less_then_or_equal: 2.0 }
end
