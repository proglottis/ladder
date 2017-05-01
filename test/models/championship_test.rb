require 'test_helper'

describe Championship do
  before do
    @championship = create(:championship)
  end

  describe ".incomplete" do
    it "finds championships with incomplete matches" do
      create(:match, championship: @championship, game: nil)
      Championship.incomplete.must_include @championship
    end

    it "wont find championships with all matches complete" do
      create(:match, championship: @championship, game: create(:game))
      Championship.incomplete.wont_include @championship
    end
  end

  describe ".started" do
    it "wont find championships that have not been started" do
      Championship.started.wont_include @championship
    end

    it "finds championships which have been started" do
      @championship.update_attributes! started_at: Time.zone.now
      Championship.started.must_include @championship
    end

    it "wont find championships that have been ended" do
      @championship.update_attributes! started_at: Time.zone.now, ended_at: Time.zone.now
      Championship.started.wont_include @championship
    end
  end

  describe ".active" do
    before do
      @championship.update_attributes!(started_at: 2.days.ago, ended_at: 1.day.ago)
    end

    it "finds championship created but not started" do
      championship = create(:championship)
      Championship.active.must_equal championship
    end

    it "finds championship started but not ended" do
      championship = create(:championship, started_at: Time.zone.now)
      Championship.active.must_equal championship
    end

    it "finds latest championship that ended" do
      Championship.active.must_equal @championship
      championship = create(:championship, started_at: Time.zone.now, ended_at: Time.zone.now)
      Championship.active.must_equal championship
    end

    it "returns nil if there are no championships" do
      Championship.all.destroy_all
      assert_nil Championship.active
    end
  end

  describe "#start!" do
    before do
      create_list(:championship_player, 3, championship: @championship)
    end

    it "deletes any existing matches" do
      match = create(:match, championship: @championship)
      @championship.start!
      @championship.matches.wont_include match
    end

    it "sets the started_at flag" do
      @championship.start!
      @championship.started_at.wont_equal nil
    end

    describe "3 players" do
      it "creates starting matches tree" do
        # W-W
        #    \
        #     W
        #    /
        #   L
        @championship.start!
        @championship.matches.group(:bracket).count.must_equal(
          'winners' => 3,
          'losers'  => 1
        )
      end

      it "creates starting matches for every player" do
        @championship.start!
        @championship.reload
        players = (@championship.matches.map(&:player1) + @championship.matches.map(&:player2)).compact.sort_by(&:id)
        players.must_equal @championship.players.sort_by(&:id)
      end
    end

    describe "7 players" do
      before do
        create_list(:championship_player, 4, championship: @championship)
      end

      it "creates starting matches tree" do
        # W
        #  \
        #   W
        #  / \
        # W   \
        #      W
        #     / \
        # W-W    \
        #         \
        #          W
        # L-L     /
        #    \   /
        #     L-L
        #    /
        #   L
        @championship.start!
        @championship.matches.group(:bracket).count.must_equal(
          'winners' => 7,
          'losers'  => 5
        )
      end

      it "creates starting matches for every player" do
        @championship.start!
        @championship.reload
        players = (@championship.matches.map(&:player1) + @championship.matches.map(&:player2)).compact.sort_by(&:id)
        players.must_equal @championship.players.sort_by(&:id)
      end
    end

    describe "8 players" do
      before do
        create_list(:championship_player, 5, championship: @championship)
      end

      it "creates starting matches tree" do
        # W
        #  \
        #   W
        #  / \
        # W   \
        #      W
        # W   / \
        #  \ /   \
        #   W     \
        #  /       \
        # W         W
        #          /
        # L-L     /
        #    \   /
        #     L-L
        #    /
        # L-L
        @championship.start!
        @championship.matches.group(:bracket).count.must_equal(
          'winners' => 8,
          'losers'  => 6
        )
      end

      it "creates starting matches for every player" do
        @championship.start!
        @championship.reload
        players = (@championship.matches.map(&:player1) + @championship.matches.map(&:player2)).compact.sort_by(&:id)
        players.must_equal @championship.players.sort_by(&:id)
      end
    end

  end

  describe "#log_game!" do
    before do
      @tournament = @championship.tournament
      @player1, @player2, @player3 = create_list(:player, 3, tournament: @tournament)
      create(:championship_player, championship: @championship, player: @player1)
      create(:championship_player, championship: @championship, player: @player2)
      create(:championship_player, championship: @championship, player: @player3)
      @championship.start!
      @match = @championship.matches.winners.where.not(player1_id: nil, player2_id: nil).first!
      @game = create(:confirmed_game, tournament: @tournament)
      create(:game_rank, game: @game, player: @match.player1, position: 1)
      create(:game_rank, game: @game, player: @match.player2, position: 2)
    end

    it "assigns the game to the match with the correct players" do
      @championship.log_game!(@game)
      @match.reload.game.must_equal @game
    end

    it "adds winning player to next match" do
      @championship.log_game!(@game)
      @match.reload.winners_match.player2.must_equal @match.player1
    end

    it "adds losing player to the losing bracket" do
      @championship.log_game!(@game)
      @championship.matches.losers.find_by!(player1: @match.player2)
    end

    it "returns newly allocated winners match" do
      match = @championship.matches.where(player1: [@player1, @player2, @player3], player2: nil).first!
      result = @championship.log_game!(@game)
      result.must_include match
      result.length.must_equal 1
    end

    it "returns newly allocated losers match" do
      match = @championship.matches.losers.first
      match.update_attributes(player1: @player3)
      result = @championship.log_game!(@game)
      result.must_include match
      result.length.must_equal 2
    end

    describe "final" do
      before do
        # First winners game
        game = create(:confirmed_game, tournament: @tournament)
        create(:game_rank, game: game, player: @player1, position: 1)
        create(:game_rank, game: game, player: @player2, position: 2)
        @championship.log_game!(game)
        # Second winners game
        game = create(:confirmed_game, tournament: @tournament)
        create(:game_rank, game: game, player: @player1, position: 1)
        create(:game_rank, game: game, player: @player3, position: 2)
        @championship.log_game!(game)
        # Losers game
        game = create(:confirmed_game, tournament: @tournament)
        create(:game_rank, game: game, player: @player2, position: 1)
        create(:game_rank, game: game, player: @player3, position: 2)
        @championship.log_game!(game)
      end

      it "adds a special final match when the loser of the final has not lost before" do
        game = create(:confirmed_game, tournament: @tournament)
        create(:game_rank, game: game, player: @player2, position: 1)
        create(:game_rank, game: game, player: @player1, position: 2)
        @championship.log_game!(game)
        assert_nil @championship.reload.ended_at
        game.match.wont_equal nil
        @championship.matches.group(:bracket).count.must_equal(
          'winners' => 4,
          'losers'  => 1
        )
      end

      it "returns the special final match" do
        previous_matches = @championship.matches.to_a
        game = create(:confirmed_game, tournament: @tournament)
        create(:game_rank, game: game, player: @player2, position: 1)
        create(:game_rank, game: game, player: @player1, position: 2)
        result = @championship.log_game!(game)
        previous_matches.each do |match|
          result.wont_include match
        end
        result.length.must_equal 1
      end

      it "wont add a special final match when one has already been created" do
        game = create(:confirmed_game, tournament: @tournament)
        create(:game_rank, game: game, player: @player2, position: 1)
        create(:game_rank, game: game, player: @player1, position: 2)
        @championship.log_game!(game)
        @championship.reload
        game = create(:confirmed_game, tournament: @tournament)
        create(:game_rank, game: game, player: @player1, position: 1)
        create(:game_rank, game: game, player: @player2, position: 2)
        @championship.log_game!(game)
        @championship.reload.ended_at.wont_equal nil
        @championship.matches.group(:bracket).count.must_equal(
          'winners' => 4,
          'losers'  => 1
        )
      end

      it "sets the ended_at flag" do
        game = create(:confirmed_game, tournament: @tournament)
        create(:game_rank, game: game, player: @player1, position: 1)
        create(:game_rank, game: game, player: @player2, position: 2)
        @championship.log_game!(game)
        @championship.reload.ended_at.wont_equal nil
      end
    end
  end

  describe "#update_if_ended!" do
    before do
      @player1 = create(:championship_player, championship: @championship).player
      @player2 = create(:championship_player, championship: @championship).player
      @championship.start!
      @match = @championship.matches.reload.first
    end

    it "wont set ended_at when some matches have not been played" do
      @championship.update_if_ended!
      assert_nil @championship.ended_at
    end

    it "sets ended_at when all matches have been played" do
      @match.update_attributes!(game: create(:game))
      @championship.update_if_ended!
      @championship.ended_at.wont_equal nil
    end
  end

  describe "#champions" do
    before do
      @player1 = create(:player)
      @player2 = create(:player)
      @game = create(:game)
      create(:game_rank, game: @game, player: @player1, position: 1)
      create(:game_rank, game: @game, player: @player2, position: 2)
      create(:match, championship: @championship, player1: @player1, player2: @player2, game: @game)
    end

    it "finds first and second place in order" do
      @championship.champions.must_equal [@player1, @player2]
    end
  end
end
