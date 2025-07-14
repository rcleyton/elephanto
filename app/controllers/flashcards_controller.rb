# typed: false
# frozen_string_literal: true

class FlashcardsController < ApplicationController
  before_action :set_deck
  before_action :set_flashcard, only: %i[show review]

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
      flash.now[:error] = t("messages.validation")
      render :new, status: :unprocessable_entity
    end
  end

  def review
    unless Flashcard.difficulties.key?(params[:difficulty])
      redirect_to deck_flashcard_path(@deck, @flashcard), alert: "Dificuldade inválida"
      return
    end

    @flashcard.difficulty = params[:difficulty]
    @flashcard.review!

    queue = session[:review_queue] || []
    queue.delete(@flashcard.id)

    if @flashcard.difficulty == "again"
      queue << @flashcard.id
    end

    session[:review_queue] = queue

    if queue.any?
      redirect_to deck_flashcard_path(@deck, queue.first)
    else
      session.delete(:review_queue)
      flash[:notice] = t("messages.completed_review")
      redirect_to deck_path(@deck)
    end
  end

  def start_review
    flashcards = @deck.flashcards.due.order(:next_review).pluck(:id)

    if flashcards.any?
      session[:review_queue] = flashcards
      redirect_to deck_flashcard_path(@deck, flashcards.first)
    else
      flash[:notice] = t("messages.no_revision_today")
      redirect_to deck_path(@deck)
    end
  end

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
end
