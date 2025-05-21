# typed: false
# frozen_string_literal: true

class FlashcardsController < ApplicationController
  before_action :set_deck
  before_action :set_flashcard, only: %i[show]

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
      render :new, status: :unprocessable_entity
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