require "test_helper"

describe Deck do
  setup do
    @user = users(:one)
    @deck = decks(:english)
  end

  describe "validations" do
    it "requires name, description, and tag" do
      deck = Deck.new(user: @user)

      expect(deck.valid?).must_equal false

      deck.name = "Vocabulário"
      deck.description = "Cards para revisar vocabulário"
      deck.tag = "Language"

      expect(deck.valid?).must_equal true
    end
  end

  describe "scopes" do
    it "returns only favorite decks" do
      favorite_deck = Deck.create!(
        name: "Favoritos",
        description: "Deck favorito",
        tag: "Priority",
        user: @user,
        favorite: true
      )
      non_favorite_deck = Deck.create!(
        name: "Plano B",
        description: "Deck normal",
        tag: "Regular",
        user: @user,
        favorite: false
      )

      expect(Deck.favorites).must_include favorite_deck
      expect(Deck.favorites).wont_include non_favorite_deck
    end

    it "returns only archived decks" do
      archived_deck = Deck.create!(
        name: "Arquivados",
        description: "Deck antigo",
        tag: "History",
        user: @user,
        archived: true
      )
      active_deck = Deck.create!(
        name: "Ativos",
        description: "Deck atual",
        tag: "Current",
        user: @user,
        archived: false
      )

      expect(Deck.archived).must_include archived_deck
      expect(Deck.archived).wont_include active_deck
    end
  end

  describe "#toggle_favorite!" do
    it "flips the favorite flag" do
      @deck.update!(favorite: false)

      @deck.toggle_favorite!
      expect(@deck.reload.favorite).must_equal true

      @deck.toggle_favorite!
      expect(@deck.reload.favorite).must_equal false
    end
  end

  describe "cover color assignment" do
    it "runs the gradient picker when cover color is blank" do
      Deck.stub(:random_gradient, "linear-gradient(90deg, #000, #fff)") do
        gradient_deck = Deck.create!(
          name: "Gradiente",
          description: "Deck novo",
          tag: "Design",
          user: @user
        )

        expect(gradient_deck.cover_color).must_equal "linear-gradient(90deg, #000, #fff)"
      end
    end
  end
end
