# typed: false
# frozen_string_literal: true

require "test_helper"

class DecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deck         = decks(:english)
    @user         = users(:one)

    post session_url, params: {  email_address: @user.email_address, password: "P@ssword1" }
  end

  it "should get index" do
    get decks_url
    assert_response :success
  end

  it "should get new" do
    get new_deck_url
    assert_response :success
  end

  it "should create deck" do
    new_deck_name        = "Programming Concepts"
    new_deck_description = "Fundamental programming concepts and definitions"

    assert_difference("Deck.count") do
      post decks_url, params: { deck: { description: new_deck_description, name: new_deck_name, user_id: @user } }
    end

    assert_redirected_to deck_url(Deck.last)
  end

  it "should show deck" do
    get deck_url(@deck)
    assert_response :success
  end

  it "user cannot access another deck" do
    other_user = users(:two)
    other_deck = other_user.decks.create!(name: "Private", description: "Access denied")

    get deck_url(other_deck)

    assert_redirected_to decks_url
    assert_equal I18n.t("messages.render_not_found"), flash[:alert]
  end

  it "should get edit" do
    get edit_deck_url(@deck)
    assert_response :success
  end

  it "should update deck" do
    patch deck_url(@deck), params: { deck: { description: @deck.description, name: @deck.name } }
    assert_redirected_to deck_url(@deck)
  end

  it "should destroy deck" do
    assert_difference("Deck.count", -1) do
      delete deck_url(@deck)
    end

    assert_redirected_to decks_url
  end

  it "must have a profile" do
    @another_user        = users(:two)
    new_deck_name        = "Programming Concepts"
    new_deck_description = "Fundamental programming concepts and definitions"

    @another_user.confirm!

    post session_url, params: {  email_address: @another_user.email_address, password: "P@ssword1" }

    post decks_url, params: { deck: { description: new_deck_description, name: new_deck_name } }

    assert_equal @another_user.profile.present?, false
    assert_redirected_to new_profile_url
    assert_equal I18n.t("messages.missing_profile"), flash[:alert]
  end
end
