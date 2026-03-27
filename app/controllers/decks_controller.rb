# typed: false
# frozen_string_literal: true

class DecksController < ApplicationController
  include ActionView::RecordIdentifier
  include ProfileRequired

  before_action :required_profile, only: [ :new, :create ]
  before_action :set_deck, only: %i[ show edit update destroy ]

  def index
    @decks = current_user.decks.order(:created_at)

    case params[:filter]
    when "recent"
      @decks = @decks.recent
    when "favorites"
      @decks = @decks.favorites
    when "archived"
      @decks = @decks.archived
    else
      @decks = @decks.where(archived: false)
    end
  end

  def show
    @flashcards    = @deck.flashcards.page(params[:page]).per(10)
    @status_counts = {
      new:        @deck.flashcards.new_state.count,
      learning:   @deck.flashcards.learning_state.count,
      review:     @deck.flashcards.review_state.count,
      relearning: @deck.flashcards.relearning_state.count
    }
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
      flash.now[:error] = t("messages.fill_all_fields")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @deck.update(deck_params)
      flash[:notice] = t("messages.updated", model: Deck.model_name.human)
      redirect_to deck_path(@deck)
    else
      flash.now[:error] = t("messages.fill_all_fields")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @deck.destroy!
      flash[:success] = t("messages.deleted", model: Deck.model_name.human)
      redirect_to decks_path, status: :see_other
    end
  end

  def toggle_favorite
    @deck = Deck.find(params[:id])
    @deck.toggle_favorite!

    respond_to do |format|
      format.turbo_stream do
        streams = []

        if params[:filter] == "favorites" && !@deck.favorite?
          streams << turbo_stream.remove(helpers.dom_id(@deck))

          if Deck.favorites.none?
            streams << turbo_stream.replace(
              "decks_list",
              partial: "decks/empty_state",
              locals: { filter: "favorites" }
            )
          end
        else
          streams << turbo_stream.replace(
            "#{helpers.dom_id(@deck)}_favorite_icon",
            partial: "decks/favorite_icon",
            locals: { deck: @deck }
          )
        end

        render turbo_stream: streams
      end

      format.html { redirect_to decks_path(filter: params[:filter]) }
    end
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:id])
  end

  def deck_params
    params.expect(deck: [ :name, :description, :tag, :cover_image, :cover_color ])
  end
end
