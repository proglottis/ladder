require "test_helper"

describe RatingPeriod do
  before do
    @tournament = create(:tournament)
  end

  describe "#previous_rating_period" do
    before do
      @period1 = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2010))
      @period2 = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2011))
      @period3 = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2013))
      @other_period = create(:rating_period, :period_at => Time.new(2013))
    end

    it "must find previous period by period date" do
      @period2.previous_rating_period.must_equal @period1
      @period3.previous_rating_period.must_equal @period2
    end

    it "must return nil if first period" do
      assert_nil @period1.previous_rating_period
    end

    it "wont return periods on a different tournament" do
      assert_nil @other_period.previous_rating_period
    end
  end

  describe "#games" do
    before do
      @period1 = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2010))
      @period2 = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2011))
      @period3 = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2012))
      travel_to(Time.new(2010, 6))
      @game1 = create(:confirmed_game, :tournament => @tournament)
      @game2 = create(:confirmed_game, :tournament => @tournament)
      travel_to(Time.new(2011, 6))
      @game3 = create(:confirmed_game, :tournament => @tournament)
      travel_to(Time.new(2012))
    end

    it "must return games between previous period and current period" do
      @period2.games.must_include @game1
      @period2.games.must_include @game2
    end

    it "wont return games between other periods" do
      @period2.games.wont_include @game3
    end

    it "wont return unconfirmed games" do
      @game = create(:game, :tournament => @tournament)
      @period2.games.wont_include @game
    end

    it "wont return confirmed games for different tournament" do
      @game = create(:game)
      @period2.games.wont_include @game
    end
  end

  describe "#process!" do
    before do
      @player1 = create(:player)
      @player2 = create(:player)
      @player3 = create(:player)

      @period1 = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2010))
      @period2 = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2011))
      @period3 = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2012))

      @rating1 = create(:rating, :rating_period => @period1, :player => @player1)
      @rating2 = create(:rating, :rating_period => @period1, :player => @player2)
    end

    it "must do nothing when no previous" do
      ratings = @period1.ratings
      @period1.process!
      @period1.ratings.must_equal ratings
    end

    it "must create ratings from previous period players" do
      @period2.process!
      @period2.ratings.map(&:player).must_equal @period1.ratings.map(&:player)
    end

    it "must update existing ratings" do
      @rating3 = create(:rating, :rating_period => @period2, :player => @player3)
      @period2.process!
      @period2.ratings.must_include @rating3
    end

    it "must update ratings based on games" do
      travel_to(Time.new(2010, 6))
      @game = create(:confirmed_game, :tournament => @tournament)
      @game_rank1 = create(:game_rank, :game => @game, :player => @player1, :position => 1)
      @game_rank2 = create(:game_rank, :game => @game, :player => @player2, :position => 2)
      travel_to(Time.new(2012))

      @period2.process!

      @period1.ratings.find_by!(player: @player1).rating.wont_equal @period2.ratings.find_by!(player: @player1).rating
      @period1.ratings.find_by!(player: @player2).rating.wont_equal @period2.ratings.find_by!(player: @player2).rating
    end
  end

  describe "#update_player_positions!" do
    before do
      @player1 = create(:player)
      @player2 = create(:player)
      @player3 = create(:player)

      @period = create(:rating_period, :tournament => @tournament, :period_at => Time.new(2010))

      @rating1 = create(:rating, :rating_period => @period, :player => @player1)
      @rating2 = create(:rating, :rating_period => @period, :player => @player2)
    end

    describe "when the tournament is using 'king of the hill' ranking" do
      before do
        @tournament.update_attributes!(:ranking_type => 'king_of_the_hill')
      end
      it "does nothing" do
        @period.update_player_positions!
        assert_nil @player1.reload.position
        assert_nil @player2.reload.position
      end
    end

    it "must set positions of players when ranks are equal" do
      @period.update_player_positions!

      assert_equal 1, @player1.reload.position
      assert_equal 1, @player2.reload.position
      assert_nil @player3.reload.position
    end

    it "must set positions of players when ranks are not equal" do
      @rating1.update_attributes! :rating => @rating1.rating + 100

      @period.update_player_positions!

      assert_equal 1, @player1.reload.position
      assert_equal 2, @player2.reload.position
      assert_nil @player3.reload.position
    end

    it "must set position of ended player to nil" do
      @player1.update_attributes! :end_at => Time.new(2009)

      @period.update_player_positions!

      assert_nil @player1.reload.position
      assert_equal 1, @player2.reload.position
    end
  end
end
