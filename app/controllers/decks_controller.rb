# typed: false
# frozen_string_literal: true

class DecksController < ApplicationController
  before_action :require_profile, only: [ :new, :create ]
  before_action :set_deck, only: %i[ show edit update destroy ]

  def index
    @decks = current_user.decks
  end

  def show
    @flashcards = @deck.flashcards
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
      flash.now[:error] = t("messages.validation")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @deck.update(deck_params)
      flash[:notice] = t("messages.updated", model: Deck.model_name.human)
      redirect_to deck_path(@deck)
    else
      flash.now[:error] = t("messages.validation")
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

    def require_profile
      unless current_user.profile.present?
        flash[:alert] = t("messages.missing_profile")
        redirect_to new_profile_path
      end
    end
end
