require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  test "demo seeds are repeatable and use associations instead of fixed IDs" do
    unrelated_deck = users(:two).decks.create!(name: "English Vocabulary", description: "Unrelated", tag: "Private")

    load Rails.root.join("db/seeds.rb")
    counts = seed_record_counts
    user = User.find_by!(email_address: "user1@elephanto.com")
    deck = user.decks.find_by!(name: "English Vocabulary")
    card = deck.flashcards.find_by!(front: "Big")
    card.rate!(Fsrs::Rating::GOOD)
    reviewed_state = card.reload.fsrs_state
    user.update!(password: "ChangedP@ssword2", password_confirmation: "ChangedP@ssword2")

    load Rails.root.join("db/seeds.rb")

    assert_equal counts, seed_record_counts
    assert_empty unrelated_deck.flashcards
    assert_equal 10, deck.flashcards.count
    assert_equal reviewed_state, card.reload.fsrs_state
    assert user.reload.authenticate("ChangedP@ssword2")

    demo_user = User.find_by!(email_address: "user3@elephanto.com")
    assert_equal "bia.sustainable.life", demo_user.profile.username
    assert demo_user.profile.avatar.attached?
    assert_equal demo_user, Deck.find_by!(name: "History Dates").user
  end

  test "demo seeds do not create records in production" do
    counts = seed_record_counts

    Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
      capture_io { load Rails.root.join("db/seeds.rb") }
    end

    assert_equal counts, seed_record_counts
  end

  private

  def seed_record_counts
    [ User, Profile, Deck, Flashcard, ActiveStorage::Attachment, ActiveStorage::Blob ].map(&:count)
  end
end
