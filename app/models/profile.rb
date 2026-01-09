# typed: false
# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user

  has_one_attached :avatar

  validates :first_name,   presence: true
  validates :last_name,    presence: true
  validates :username,     presence: true, uniqueness: true
  validates :bio,          presence: true
  validates :rigor_factor, inclusion: { in: [2.5, 4.0, 9.0, 32.3] }
end
