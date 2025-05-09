# typed: false
# frozen_string_literal: true

require "test_helper"

class DecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deck = decks(:english)
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
    assert_difference("Deck.count") do
      post decks_url, params: { deck: { description: @deck.description, name: @deck.name } }
    end

    assert_redirected_to deck_url(Deck.last)
  end

  it "should show deck" do
    get deck_url(@deck)
    assert_response :success
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
end
