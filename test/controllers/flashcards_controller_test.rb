# typed: false
# frozen_string_literal: true

require "test_helper"

class FlashcardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deck       = decks(:english)
    @flashcard  = @deck.flashcards.create(front: "Question",  back: "Answer", difficulty: "easy")
    @flashcard2 = @deck.flashcards.create(front: "Question2", back: "Answer2")
    @user       = users(:one)

    post session_url, params: {  email_address: @user.email_address, password: "P@ssword1" }
    assert_response :redirect
  end

  context "flashcard" do
    it "should get new" do
      get new_deck_flashcard_path(@deck)
      must_respond_with :success
    end

    it "should show flashcard" do
      get deck_flashcard_url(@deck, Flashcard.last)
      must_respond_with :success
    end

    it "edit" do
      get edit_deck_flashcard_path(@deck, @flashcard)
      assert_response :success
    end

    it "update" do
      patch deck_flashcard_path(@deck, @flashcard), params: { flashcard: { back: "Another question",
                                                                          front: "Another answer" } }

      @flashcard.reload

      assert_equal "Another question", @flashcard.back
      assert_equal "Another answer",   @flashcard.front
      assert_redirected_to deck_path(@deck)
    end

    it "delete" do
      assert_difference("Flashcard.count", -1) do
        delete deck_flashcard_path(@deck, @flashcard)
      end

      assert_redirected_to deck_path(@deck)
    end
  end

  context "create" do
    it "should create flashcard" do
      assert_difference("Flashcard.count") do
        post deck_flashcards_path(@deck), params: { flashcard: { back: @flashcard.back,
                                                                difficulty: @flashcard.difficulty,
                                                                front: @flashcard.front,
                                                                last_reviewed_at: @flashcard.last_reviewed_at } }
      end

      must_redirect_to new_deck_flashcard_path(@deck)
    end

    it "front cannot be empty" do
      post deck_flashcards_path(@deck), params: { flashcard: { back: @flashcard.back, front: "" } }

      assert_response :unprocessable_entity
      assert_template :new
    end

    it "back cannot be empty" do
      post deck_flashcards_path(@deck), params: { flashcard: { back: "", front: @flashcard.front } }

      assert_response :unprocessable_entity
      assert_template :new
    end

    it "difficult can be blank" do
      assert_difference("Flashcard.count") do
        post deck_flashcards_path(@deck), params: { flashcard: { back: @flashcard.back,
                                                                front: @flashcard.front,
                                                                difficulty: "" } }
      end

      must_redirect_to new_deck_flashcard_path(@deck)
    end
  end

  context "review flashcards" do
    it "should review flashcard and redirect to next one" do
      get review_deck_path(@deck)
      assert_response :redirect

      post review_deck_flashcard_path(@deck, @flashcard), params: { difficulty: "easy" }

      @flashcard.reload
      assert_not_nil @flashcard.last_reviewed_at
      assert_equal "easy", @flashcard.difficulty

      assert_redirected_to deck_flashcard_path(@deck, @flashcard2)
    end

    it "should redirect to deck when no next flashcard" do
      @flashcard.update!(
        next_review:      1.day.from_now,
        last_reviewed_at: Time.current,
        difficulty:       "easy"
      )

      @flashcard2.update!(
        next_review:      Time.current,
        last_reviewed_at: nil,
        difficulty:       nil
      )

      post review_deck_flashcard_path(@deck, @flashcard2), params: { difficulty: "medium" }

      @flashcard2.reload
      assert_not_nil @flashcard2.last_reviewed_at
      assert_equal "medium", @flashcard2.difficulty

      assert_redirected_to reviewed_completed_deck_path(@deck)
      follow_redirect!
    end

    it "update last_reviewed_at after review" do
      post review_deck_flashcard_path(@deck, @flashcard),  params: { difficulty: "easy" }
      post review_deck_flashcard_path(@deck, @flashcard2), params: { difficulty: "easy" }

      @deck.reload
      assert_not_nil @deck.last_reviewed_at
      assert_in_delta Time.current, @deck.last_reviewed_at, 1.second
    end

    it "check period to before review" do
      flashcard = @flashcard
      flashcard.update(next_review: Time.current + 172800)
      flashcard.reload

      get deck_flashcard_path(@deck, flashcard)

      assert_redirected_to deck_path(@deck)
      follow_redirect!
    end
  end

  context "Rigor factor" do
    setup do
      @flashcard.update!(repetition: 0, last_reviewed_at: nil, stability: 0.1)
    end

    it "normal rigor (9.0) sets standar interval" do
      @flashcard.review!("easy", @user)

      assert_equal 11, @flashcard.interval
      assert_equal Date.current + 11.days, @flashcard.next_review.to_date
    end

    it "relaxed rigor (4.0) shortens intervals (accepts more forgetting)" do
      @user.profile.update!(rigor_factor: 4.0)

      @flashcard.review!("easy", @user)

      assert_equal 5, @flashcard.interval
      assert_equal Date.current + 5.days, @flashcard.next_review.to_date
    end

    it "high rigor (19.0) increases frequency by shortening stability-to-interval ratio" do
      @user.profile.update!(rigor_factor: 2.5)
    
      @flashcard.review!("easy", @user)

      assert_equal 3, @flashcard.interval
      assert_equal Date.current + 3.days, @flashcard.next_review.to_date
    end

    it "maximum rigor (32.3) provides longest intervals for high retention (97%)" do
      @user.profile.update!(rigor_factor: 32.3)
    
      @flashcard.review!("easy", @user)

      assert_equal 39, @flashcard.interval
      assert_equal Date.current + 39.days, @flashcard.next_review.to_date
    end
  end
end
