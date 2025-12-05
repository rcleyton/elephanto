# typed: false
# frozen_string_literal: true

class DecksController < ApplicationController
  include ProfileRequired

  before_action :required_profile, only: [ :new, :create ]
  before_action :set_deck, only: %i[ show edit update destroy ]

  def index
    @decks = current_user.decks.order(:created_at)
  end

  def show
    @flashcards = @deck.flashcards.page(params[:page]).per(10)
  end

  def new
    @deck = Deck.new
  end

  def edit; end

  def create
    @deck = current_user.decks.build(deck_params)
    if @deck.save
      flash[:success] = t("messages.created", model: Deck.model_name.human)
      redirect_to deck_path(@deck)
    else
      flash.now[:error] = @deck.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @deck.update(deck_params)
      flash[:notice] = t("messages.updated", model: Deck.model_name.human)
      redirect_to deck_path(@deck)
    else
      flash.now[:error] = @deck.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @deck.destroy!
      flash[:success] = t("messages.deleted", model: Deck.model_name.human)
      redirect_to decks_path, status: :see_other
    end
  end

  private
  
  def set_deck
    @deck = current_user.decks.find(params[:id])
  end

  def deck_params
    params.expect(deck: [ :name, :description ])
  end
end
