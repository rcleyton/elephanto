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
      flash.now[:error] = @flashcard.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @flashcard.update(flashcard_params)
      redirect_to deck_path(@deck)
      flash[:notice] = t("messages.updated", model: Flashcard.model_name.human)
    else
      flash.now[:error] = @flashcard.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @flashcard.destroy!
      flash[:success] = t("messages.deleted", model: Flashcard.model_name.human)
      redirect_to deck_path(@deck)
    end
  end

  def review
    unless Flashcard.difficulties.key?(params[:difficulty])
      redirect_to deck_flashcard_path(@deck, @flashcard), alert: "Dificuldade inválida"
      return
    end

    @flashcard.difficulty = params[:difficulty]
    @flashcard.review!(current_user)

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
      @deck.update(last_reviewed_at: Time.current)
      redirect_to reviewed_completed_deck_path(@deck)
    end
  end

  def start_review
    flashcards = @deck.flashcards.due.order(:next_review).pluck(:id)

    if flashcards.any?
      session[:review_queue] = flashcards
      session[:review_total] = flashcards.size
      redirect_to deck_flashcard_path(@deck, flashcards.first)
    else
      flash[:notice] = t("messages.no_revision_today")
      redirect_to deck_path(@deck)
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
end
