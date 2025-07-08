# typed: false
# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :decks

  validates :email_address,         presence: true, uniqueness: true, email: true
  validates :password,              presence: true, length: { minimum: 8 }, password: true
  validates :password_confirmation, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
