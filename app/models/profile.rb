# typed: false
# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user

  has_one_attached :avatar

  before_create :initialize_daily_limits

  validates :first_name,         presence: true
  validates :last_name,          presence: true
  validates :username,           presence: true, uniqueness: true
  validates :bio,                presence: true
  validates :daily_new_limit,    presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :daily_review_limit, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :rigor_factor, inclusion: { in: [ 2.5, 4.0, 9.0, 32.3 ] }

  private

  def initialize_daily_limits
    self.daily_new_limit    ||= 20
    self.daily_review_limit ||= 100
  end
end
