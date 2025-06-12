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
      flash[:success] = "Deck was successfully created." 
      redirect_to deck_path(@deck)
    else
      flash.now[:error] = "Verifique o(s) campo(s) em vermelho!"
      render :new, status: :unprocessable_entity 
    end
  end

  def update
    if @deck.update(deck_params)
      flash[:notice] = "Deck was successfully updated."
      redirect_to deck_path(@deck)
    else
      flash.now[:error] = "Verifique o(s) campo(s) em vermelho!"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @deck.destroy!
      flash[:success] = "Deck was successfully destroyed."
      redirect_to decks_path, status: :see_other
    end
  end

  private
    def set_deck
      @deck = Deck.find(params[:id])
    end

    def deck_params
      params.expect(deck: [ :name, :description ])
    end
end
