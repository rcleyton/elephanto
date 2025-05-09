class DecksController < ApplicationController
  before_action :set_deck, only: %i[ show edit update destroy ]

  def index
    @decks = Deck.all
  end

  def show;
    @flashcards = @deck.flashcards
  end

  def new
    @deck = Deck.new
  end

  def edit; end

  def create
    @deck = Deck.new(deck_params)
    if @deck.save
      redirect_to @deck, notice: "Deck was successfully created." 
    else
      render :new, status: :unprocessable_entity 
    end
  end

  def update
    if @deck.update(deck_params)
      redirect_to @deck, notice: "Deck was successfully updated." 
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to decks_path, status: :see_other, notice: "Deck was successfully destroyed." if @deck.destroy!
  end

  private
    def set_deck
      @deck = Deck.find(params[:id])
    end

    def deck_params
      params.expect(deck: [ :name, :description ])
    end
end
