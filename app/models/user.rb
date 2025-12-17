# typed: false
# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :decks,    dependent: :destroy
  has_many :flashcards, through: :decks

  has_one :profile, dependent: :destroy

  validates :email_address,         presence: true, uniqueness: true, email: true
  validates :password,              presence: true, length: { minimum: 8 }, password: true
  validates :password_confirmation, presence: true
  validates :terms_of_service,      acceptance: true, on: :create

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  before_create :generate_confirmation_token

  def confirmed?
    verified && confirmed_at.present?
  end

  def confirm!
    update_columns(confirmed_at: Time.current, confirmation_token: nil, verified: true)
  end

  def generate_confirmation_token
    self.confirmation_token   = SecureRandom.urlsafe_base64
    self.confirmation_sent_at = Time.current
  end
end
