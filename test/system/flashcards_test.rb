# typed: false
# frozen_string_literal: true

require "application_system_test_case"

class FlashcardsTest < ApplicationSystemTestCase
  setup do
    @deck      = decks(:english)
    @flashcard = flashcards(:one)
    @user      = users(:one)
  end

  def login
    visit new_session_url

    fill_in :email_address, with: @user.email_address
    fill_in :password,      with: "p@ssword1"

    click_on I18n.t("buttons.general.enter")
  end

  it "visits the index" do
    login
    find("#deck_#{@deck.id}").click
    assert_selector "h3", text: "Flashcards"
  end

  it "creates a Flashcard" do
    login
    find("#deck_#{@deck.id}").click
    click_on I18n.t("buttons.submit.new_flashcard")

    fill_in I18n.t("placeholders.flashcard.front_flashcard"), with: @flashcard.front
    fill_in I18n.t("placeholders.flashcard.back_flashcard"), with: @flashcard.back
    click_on "Criar Flashcard"

    assert_text I18n.t("messages.created", model: Flashcard.model_name.human)
  end
end
