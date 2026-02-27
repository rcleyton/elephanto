# typed: false
# frozen_string_literal: true

class FlashcardsController < ApplicationController
  before_action :set_deck
  before_action :set_flashcard, only: %i[show edit update destroy review]

  def show; end

  def new
    @flashcard = @deck.flashcards.build
  end

  def create
    @flashcard = @deck.flashcards.build(flashcard_params)
    if @flashcard.save
      flash[:success] = t("messages.created", model: Flashcard.model_name.human)
      redirect_to new_deck_flashcard_path(@deck)
    else
      flash.now[:error] = t("messages.fill_all_fields")
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @flashcard.update(flashcard_params)
      redirect_to deck_path(@deck)
      flash[:notice] = t("messages.updated", model: Flashcard.model_name.human)
    else
      flash.now[:error] = t("messages.fill_all_fields")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @flashcard.destroy!
      flash[:success] = t("messages.deleted", model: Flashcard.model_name.human)
      redirect_to deck_path(@deck)
    end
  end

  def start_review
    due_ids = @deck.flashcards.all.select(&:due?).map(&:id)

    if due_ids.any?
      session[:review_queue] = due_ids

      review_session = @deck.review_sessions.create!(
        user: current_user,
        total_count: due_ids.size,
        started_at: Time.current
      )
      session[:review_session_id] = review_session.id
      session[:total_review]      = review_session.total_count

      redirect_to deck_flashcard_path(@deck, due_ids.first)
    else
      redirect_to deck_path(@deck), notice: t("messages.no_revision_today")
    end
  end

  def review
    service       = ReviewSessionService.new(current_user, @deck)
    updated_queue = service.process_review(@flashcard, params[:rating], session)

    if updated_queue.any?
      redirect_to deck_flashcard_path(@deck, updated_queue.first)
    else
      redirect_to reviewed_completed_deck_path(@deck)
    end
  end

  def reviewed_completed; end

  private

  def set_deck
    @deck = current_user.decks.find(params[:deck_id] || params[:id])
  end

  def set_flashcard
    @flashcard = @deck.flashcards.find(params[:id])
  end

  def flashcard_params
    params.require(:flashcard).permit(:front, :back)
  end
end
