require "test_helper"

describe Rating do
  describe "#for_game" do
    before do
      @tournament = create(:started_tournament)
      @rating_period = @tournament.current_rating_period
      @player1 = create(:player, :tournament => @tournament)
      @player2 = create(:player, :tournament => @tournament)
      @player3 = create(:player, :tournament => @tournament)
      @rating1 = create(:rating, :rating_period => @rating_period, :player => @player1)
      @rating2 = create(:rating, :rating_period => @rating_period, :player => @player2)
      @rating3 = create(:rating, :rating_period => @rating_period, :player => @player3)

      @game = create(:game, :tournament => @tournament)
      @rank1 = create(:game_rank, :game => @game, :player => @player1, :position => 1)
      @rank2 = create(:game_rank, :game => @game, :player => @player2, :position => 2)
    end

    it "must return ratings that correspond with game" do
      @rating_period.ratings.for_game(@game).must_include @rating1
      @rating_period.ratings.for_game(@game).must_include @rating2
      @rating_period.ratings.for_game(@game).wont_include @rating3
    end
  end

  describe "#chance_to_beat" do
    before do
      @rating1 = create(:rating, rating: 1500)
      @rating2 = create(:rating, rating: 1300)
    end

    it "roughly predicts who would win" do
      r1_v_r2 = @rating1.chance_to_beat(@rating2)
      r2_v_r1 = @rating2.chance_to_beat(@rating1)

      assert_operator r1_v_r2, :>, r2_v_r1
    end
  end
end
