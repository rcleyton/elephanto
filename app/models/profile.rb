# typed: false
# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user

  has_one_attached :avatar

  before_validation :initialize_daily_limits, on: :create

  validates :first_name,         presence: true
  validates :last_name,          presence: true
  validates :username,           presence: true, uniqueness: true
  validates :bio,                presence: true
  validates :daily_new_limit,    presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :daily_review_limit, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }

  private

  def initialize_daily_limits
    self.daily_new_limit    ||= 20
    self.daily_review_limit ||= 100
  end
end
