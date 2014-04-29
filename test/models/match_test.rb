require 'test_helper'

describe Match do
  describe ".incomplete" do
    it "must find a match with no game" do
      match = create(:match, game: nil)
      Match.incomplete.must_include match
    end

    it "wont find a match with a game" do
      match = create(:match, game: create(:game))
      Match.incomplete.wont_include match
    end
  end

  describe ".matches_game" do
    before do
      @tournament = create(:tournament)
      @player1 = create(:player, tournament: @tournament)
      @player2 = create(:player, tournament: @tournament)
      @game = create(:confirmed_game, tournament: @tournament)
      @rank1 = create(:game_rank, game: @game, position: 1, player: @player1)
      @rank2 = create(:game_rank, game: @game, position: 2, player: @player2)
      @championship = create(:championship, tournament: @tournament)
    end

    it "must find matches with the same players in any order" do
      match1 = create(:match, player1: @player1, player2: @player2, championship: @championship)
      match2 = create(:match, player1: @player2, player2: @player1, championship: @championship)
      Match.matches_game(@game).must_include match1
      Match.matches_game(@game).must_include match2
    end

    it "wont find matches where players only partially match" do
      match = create(:match, player1: @player1, player2: create(:player), championship: @championship)
      Match.matches_game(@game).wont_include match
    end

    it "wont find matches where no players match" do
      match = create(:match, player1: create(:player), player2: create(:player), championship: @championship)
      Match.matches_game(@game).wont_include match
    end

    it "wont find matches in a different tournament" do
      match = create(:match, player1: @player1, player2: @player2)
      Match.matches_game(@game).wont_include match
    end
  end

  describe ".allocated" do
    it "must find matches with both players set" do
      match = create(:match, player1: create(:player), player2: create(:player))
      Match.allocated.must_include match
    end

    it "wont find matches with one player set" do
      match1 = create(:match, player1: nil, player2: create(:player))
      match2 = create(:match, player1: create(:player), player2: nil)
      Match.allocated.wont_include match1
      Match.allocated.wont_include match2
    end

    it "wont find matches with no players set" do
      match = create(:match, player1: nil, player2: nil)
      Match.allocated.wont_include match
    end
  end

  describe ".unallocated" do
    it "must find matches with missing players" do
      match1 = create(:match, player1: nil, player2: create(:player))
      match2 = create(:match, player1: create(:player), player2: nil)
      Match.unallocated.must_include match1
      Match.unallocated.must_include match2
    end

    it "must find matches with no players" do
      match = create(:match, player1: nil, player2: nil)
      Match.unallocated.must_include match
    end

    it "wont find matches with all players allocated" do
      match = create(:match, player1: create(:player), player2: create(:player))
      Match.unallocated.wont_include match
    end
  end

  describe "#add_player" do
    before do
      @match = create(:match, player1: nil, player2: nil)
      @player = create(:player)
    end

    it "sets player1 if nil" do
      @match.add_player(@player)
      @match.player1.must_equal @player
      @match.player2.must_equal nil
    end

    it "sets player2 if player1 is set" do
      @match.player1 = create(:player)
      @match.add_player(@player)
      @match.player1.wont_equal nil
      @match.player2.must_equal @player
    end

    it "does nothing if player1 is equal" do
      @match.player1 = @player
      @match.add_player(@player)
      @match.player1.must_equal @player
      @match.player2.must_equal nil
    end

    it "does nothing if player2 is equal" do
      @match.player2 = @player
      @match.add_player(@player)
      @match.player1.must_equal nil
      @match.player2.must_equal @player
    end
  end
end
