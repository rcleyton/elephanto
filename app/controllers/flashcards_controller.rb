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
    unless Flashcard.difficulties.key?(params[:difficulty])
      redirect_to deck_flashcard_path(@deck, @flashcard), alert: "Dificuldade inválida"
      return
    end

    @flashcard.difficulty = params[:difficulty]
    @flashcard.review!

    due_flashcards = @deck.flashcards.due.order(:next_review)
    next_flashcard = due_flashcards.where.not(id: @flashcard.id).first

    if next_flashcard
      redirect_to deck_flashcard_path(@deck, next_flashcard)
    else
      redirect_to deck_path(@deck), notice: "Você revisou todos os flashcards disponíveis hoje!"
    end
  end

  def start_review
    due_flashcard = @deck.flashcards.due.order(:next_review).first

    if due_flashcard
      redirect_to deck_flashcard_path(@deck, due_flashcard)
    else
      redirect_to deck_path(@deck), notice: "Nenhum flashcard disponível para revisão hoje"
    end
  end

  private

  def set_deck
    @deck = Deck.find(params[:deck_id] || params[:id])
  end

  def set_flashcard
    @flashcard = @deck.flashcards.find(params[:id])
  end

  def flashcard_params
    params.require(:flashcard).permit(:front, :back, :difficulty, :last_reviewed_at)
  end
end
