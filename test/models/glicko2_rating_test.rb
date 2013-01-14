require "minitest_helper"

describe Glicko2Rating do
  describe ".for_game" do
    before do
      @game = create(:game)
      @game_rank1 = create(:game_rank, :game => @game)
      @game_rank2 = create(:game_rank, :game => @game)
      @game_rank3 = create(:game_rank)
      @rating1 = create(:rating, :tournament => @game.tournament, :user => @game_rank1.user)
      @rating2 = create(:rating, :tournament => @game.tournament, :user => @game_rank2.user)
      @rating3 = create(:rating, :tournament => @game.tournament, :user => @game_rank3.user)
    end

    it "must match all ratings for a game" do
      ratings = Glicko2Rating.for_game(@game)
      ratings.must_include @rating1
      ratings.must_include @rating2
    end

    it "wont match ratings for different games" do
      Glicko2Rating.for_game(@game).wont_include @rating3
    end

    it "must include ratings position" do
      Glicko2Rating.for_game(@game).first.position.must_be :>, 0
    end
  end
end
