# typed: false
# frozen_string_literal: true

class FlashcardsController < ApplicationController
  before_action :set_deck
  before_action :set_flashcard, only: %i[show edit update destroy review]
  before_action :check_review_period, only: [ :show ]

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
    service = ReviewSessionService.new(current_user, @deck)
    review_session = service.start

    if review_session
      flashcards = @deck.flashcards.due.order(:next_review).pluck(:id)

      session[:review_queue]       = flashcards
      session[:review_total]       = review_session.total_count
      session[:review_session_id]  = review_session.id

      redirect_to deck_flashcard_path(@deck, flashcards.first)
    else
      flash[:notice] = t("messages.no_revision_today")
      redirect_to deck_path(@deck)
    end
  end

  def review
    queue                  = session[:review_queue] || []
    service                = ReviewSessionService.new(current_user, @deck)
    updated_queue          = service.process_review(@flashcard, params[:difficulty], queue, session)
    session[:review_queue] = updated_queue

    if updated_queue.any?
      redirect_to deck_flashcard_path(@deck, queue.first)
    else
      session.delete(:review_queue)
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
    params.require(:flashcard).permit(:front, :back, :difficulty, :last_reviewed_at)
  end

  def check_review_period
    unless @flashcard.next_review <= Time.current
      redirect_to deck_path(@deck), alert: "Flashcard fora do período de revisão"
    end
  end
end
