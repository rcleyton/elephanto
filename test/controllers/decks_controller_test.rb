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
    new_deck_tag         = "Programming"

    assert_difference("Deck.count") do
      post decks_url, params: { deck: { description: new_deck_description, name: new_deck_name, tag: new_deck_tag, user_id: @user } }
    end

    assert_redirected_to deck_url(Deck.last)
  end

  it "should show deck" do
    get deck_url(@deck)
    assert_response :success
  end

  it "user cannot access another deck" do
    other_user = users(:two)
    other_deck = other_user.decks.create!(name: "Private", description: "Access denied", tag: "Private")

    get deck_url(other_deck)

    assert_redirected_to decks_url
    assert_equal I18n.t("messages.render_not_found"), flash[:alert]
  end

  it "should get edit" do
    get edit_deck_url(@deck)
    assert_response :success
  end

  test "toggles the current user's own deck favorite on and off" do
    patch toggle_favorite_deck_url(@deck)

    assert_redirected_to decks_url
    assert @deck.reload.favorite?

    patch toggle_favorite_deck_url(@deck)

    assert_redirected_to decks_url
    refute @deck.reload.favorite?
  end

  test "rejects a forged favorite request for another user's deck" do
    other_deck = decks(:chemical)

    [ false, true ].each do |favorite|
      other_deck.update!(favorite: favorite)

      patch toggle_favorite_deck_url(other_deck)

      assert_redirected_to decks_url
      assert_equal I18n.t("messages.render_not_found"), flash[:alert]
      assert_equal favorite, other_deck.reload.favorite?
    end
  end

  test "rejects a forged Turbo favorite request for another user's deck" do
    other_deck = decks(:chemical)

    patch toggle_favorite_deck_url(other_deck), as: :turbo_stream

    assert_redirected_to decks_url
    assert_equal I18n.t("messages.render_not_found"), flash[:alert]
    refute other_deck.reload.favorite?
  end

  test "shows the favorites empty state even when another user has favorites" do
    @deck.update!(favorite: true)
    decks(:chemical).update!(favorite: true)

    patch toggle_favorite_deck_url(@deck), params: { filter: "favorites" }, as: :turbo_stream

    assert_response :success
    refute @deck.reload.favorite?
    assert decks(:chemical).reload.favorite?
    assert_select "turbo-stream[action='remove'][target='#{ActionView::RecordIdentifier.dom_id(@deck)}']"
    assert_select "turbo-stream[action='replace'][target='decks_list']", count: 1
  end

  test "keeps the favorites list when the current user still has a favorite" do
    @deck.update!(favorite: true)
    decks(:development).update!(favorite: true)

    patch toggle_favorite_deck_url(@deck), params: { filter: "favorites" }, as: :turbo_stream

    assert_response :success
    refute @deck.reload.favorite?
    assert_select "turbo-stream[action='remove'][target='#{ActionView::RecordIdentifier.dom_id(@deck)}']"
    assert_select "turbo-stream[action='replace'][target='decks_list']", count: 0
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
