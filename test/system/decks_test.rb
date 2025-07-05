require "application_system_test_case"

class DecksTest < ApplicationSystemTestCase
  setup do
    @deck = decks(:english)
    @user = users(:one)
  end

  def login
    visit new_session_url

    fill_in :email_address, with: @user.email_address
    fill_in :password,      with: "p@ssword1"

    click_on I18n.t("buttons.general.enter")
  end

  it "visiting the index" do
    login

    assert_selector "p", text: "Decks"
  end

  it "should create deck" do
    login

    click_on I18n.t("buttons.submit.new_deck")

    fill_in  I18n.t("placeholders.deck.deck_description"), with: @deck.description
    fill_in  I18n.t("placeholders.deck.deck_name"),        with: @deck.name
    click_on "Criar Deck"

    assert_text I18n.t("messages.created", model: Deck.model_name.human)
    assert_text @deck.name
    assert_text @deck.description
  end

  it "should update Deck" do
    login

    find("#deck_#{@deck.id}").click

    click_on I18n.t("buttons.submit.edit_deck"), match: :first

    fill_in  I18n.t("placeholders.deck.deck_description"), with: @deck.description
    fill_in  I18n.t("placeholders.deck.deck_name"),        with: @deck.name
    click_on "Atualizar Deck"

    assert_text I18n.t("messages.updated", model: Deck.model_name.human)
    assert_current_path deck_path(@deck)
  end

  it "should destroy Deck" do
    login

    find("#deck_#{@deck.id}").click

    visit deck_url(@deck)
    accept_confirm { click_on I18n.t("buttons.submit.delete_deck"), match: :first }

    assert_text I18n.t("messages.deleted", model: Deck.model_name.human)
  end
end
