require "application_system_test_case"

class StudyFlowTest < ApplicationSystemTestCase
  test "a verified user can sign in and open their deck library" do
    sign_in

    assert_current_path decks_path
    assert_text decks(:english).name
    assert_text decks(:development).name
    assert_no_text decks(:chemical).name
  end

  test "a user can start a review and reveal the answer and recall ratings" do
    card = flashcards(:two)
    card.update!(fsrs_state: Fsrs::Card.new.to_h)
    sign_in
    visit deck_path(decks(:english))
    click_link I18n.t("buttons.general.start_studying")

    assert_current_path deck_flashcard_path(decks(:english), card)
    assert_text card.front
    click_button I18n.t("buttons.general.show_answer")

    assert_text card.back
    %w[again hard medium easy].each do |rating|
      assert_button I18n.t("buttons.general.#{rating}")
    end
  end

  private

  def sign_in
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "P@ssword1"
    click_button I18n.t("buttons.general.enter")
    assert_current_path decks_path
  end
end
