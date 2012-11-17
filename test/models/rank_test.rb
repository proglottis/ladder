require "minitest_helper"

describe Rank do
  describe ".for_game" do
    before do
      @game = create(:game)
      @game_rank1 = create(:game_rank, :game => @game)
      @game_rank2 = create(:game_rank, :game => @game)
      @game_rank3 = create(:game_rank)
      @rank1 = create(:rank, :tournament => @game.tournament, :user => @game_rank1.user)
      @rank2 = create(:rank, :tournament => @game.tournament, :user => @game_rank2.user)
      @rank3 = create(:rank, :tournament => @game.tournament, :user => @game_rank3.user)
    end

    it "must match all ranks for a game" do
      ranks = Rank.for_game(@game)
      ranks.must_include @rank1
      ranks.must_include @rank2
    end

    it "wont match ranks for different games" do
      Rank.for_game(@game).wont_include @rank3
    end

    it "must include rank position" do
      Rank.for_game(@game).first.position.must_be :>, 0
    end
  end

  describe "#rank" do
    let(:rank) { create(:rank) }

    it "must be zero with default values" do
      rank.mu = 25.0
      rank.sigma = 25.0 / 3.0
      rank.rank.must_equal 0.0
    end

    it "must be about 50 for maximum values" do
      rank.mu = 56.995
      rank.sigma = 1.901
      rank.rank.must_be_close_to 51.292
    end
  end
end
