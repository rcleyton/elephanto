require "application_system_test_case"

class DecksTest < ApplicationSystemTestCase
  setup do
    @deck = decks(:english)
  end

  it "visiting the index" do
    visit decks_url
    assert_selector "p", text: "Decks"
  end

  it "should create deck" do
    visit decks_url
    click_on I18n.t("buttons.submit.new_deck")

    fill_in  I18n.t("placeholders.deck.deck_description"), with: @deck.description
    fill_in  I18n.t("placeholders.deck.deck_name"),        with: @deck.name
    click_on "Criar Deck"

    assert_text I18n.t("messages.created", model: Deck.model_name.human)
    assert_text @deck.name
    assert_text @deck.description
  end

  it "should update Deck" do
    visit deck_url(@deck)
    click_on I18n.t("buttons.submit.edit_deck"), match: :first

    fill_in  I18n.t("placeholders.deck.deck_description"), with: @deck.description
    fill_in  I18n.t("placeholders.deck.deck_name"),        with: @deck.name
    click_on "Atualizar Deck"

    assert_text I18n.t("messages.updated", model: Deck.model_name.human)
    assert_current_path deck_path(@deck)
  end

  it "should destroy Deck" do
    visit deck_url(@deck)
    accept_confirm { click_on I18n.t("buttons.submit.delete_deck"), match: :first }

    assert_text I18n.t("messages.deleted", model: Deck.model_name.human)
  end
end
