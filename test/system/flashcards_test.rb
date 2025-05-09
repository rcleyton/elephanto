require "application_system_test_case"

describe "Flashcards", :system do
  let(:flashcard) { flashcards(:one) }

  it "visits the index" do
    visit flashcards_url
    assert_selector "h1", text: "Flashcards"
  end

  it "creates a Flashcard" do
    visit flashcards_url
    click_on "New flashcard"

    fill_in "Back", with: @flashcard.back
    fill_in "Deck", with: @flashcard.deck_id
    fill_in "Difficulty", with: @flashcard.difficulty
    fill_in "Front", with: @flashcard.front
    fill_in "Last reviewed at", with: @flashcard.last_reviewed_at
    click_on "Create Flashcard"

    assert_text "Flashcard was successfully created"
    click_on "Back"
  end

  it "updates a Flashcard" do
    visit flashcard_url(@flashcard)
    click_on "Edit this flashcard", match: :first

    fill_in "Back", with: @flashcard.back
    fill_in "Deck", with: @flashcard.deck_id
    fill_in "Difficulty", with: @flashcard.difficulty
    fill_in "Front", with: @flashcard.front
    fill_in "Last reviewed at", with: @flashcard.last_reviewed_at
    click_on "Update Flashcard"

    assert_text "Flashcard was successfully updated"
    click_on "Back"
  end

  it "destroys a Flashcard" do
    visit flashcard_url(@flashcard)
    click_on "Destroy this flashcard", match: :first

    assert_text "Flashcard was successfully destroyed"
  end
end
