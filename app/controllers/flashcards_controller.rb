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
      flash[:success] = "Flashcard was successfully created."
      redirect_to new_deck_flashcard_path(@deck)
    else
      flash.now[:error] = "Verifique o(s) campo(s) em vermelho!"
      render :new, status: :unprocessable_entity
    end
  end

  def review
    @flashcard.update(last_reviewed_at: Time.current, difficulty: params[:difficulty])

    flashcards     = @deck.flashcards.order(:created_at)
    current_index  = flashcards.index(@flashcard)
    next_flashcard = flashcards[current_index + 1]

    if next_flashcard
      redirect_to deck_flashcard_path(@deck, next_flashcard)
    else
      redirect_to deck_path(@deck), notice: "Você revisou todos os flashcards!"
    end
  end

  private

  def set_deck
    @deck = Deck.find(params[:deck_id])
  end

  def set_flashcard
    @flashcard = @deck.flashcards.find(params[:id])
  end

  def flashcard_params
    params.require(:flashcard).permit(:front, :back, :difficulty, :last_reviewed_at)
  end
end