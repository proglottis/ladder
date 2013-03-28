require "test_helper"

describe Rating do
  describe "#for_game" do
    before do
      @rating_period = create(:rating_period)
      @rating1 = create(:rating, :rating_period => @rating_period)
      @rating2 = create(:rating, :rating_period => @rating_period)
      @rating3 = create(:rating, :rating_period => @rating_period)

      @game = create(:game, :tournament => @rating_period.tournament)
      @rank1 = create(:game_rank, :game => @game, :user => @rating1.user, :position => 1)
      @rank2 = create(:game_rank, :game => @game, :user => @rating2.user, :position => 2)
    end

    it "must return ratings that correspond with game" do
      @rating_period.ratings.for_game(@game).must_include @rating1
      @rating_period.ratings.for_game(@game).must_include @rating2
      @rating_period.ratings.for_game(@game).wont_include @rating3
    end
  end
end
