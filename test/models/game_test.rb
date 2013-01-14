require "minitest_helper"

describe Game do
  before do
    @game = create(:game)
    @user1 = create(:user)
    @user2 = create(:user)
    @game_rank1 = create(:game_rank, :game => @game, :user => @user1, :confirmed_at => Time.zone.now, :position => 1)
    @game_rank2 = create(:game_rank, :game => @game, :user => @user2, :confirmed_at => Time.zone.now, :position => 2)
    @rank1 = create(:rank, :tournament => @game.tournament, :user => @user1)
    @rank2 = create(:rank, :tournament => @game.tournament, :user => @user2)
    @rating1 = create(:elo_rating, :tournament => @game.tournament, :user => @user1)
    @rating2 = create(:elo_rating, :tournament => @game.tournament, :user => @user2)
  end

  describe ".with_participant" do
    it "must match participant" do
      Game.with_participant(@user1).must_include @game
      Game.with_participant(@user2).must_include @game
    end

    it "wont match nonparticipant" do
      @user = create(:user)
      Game.with_participant(@user).wont_include @game
    end
  end

  describe "#confirmed?" do
    it "must be true when all game ranks are confirmed" do
      @game.confirmed?.must_equal true
    end

    it "wont be true when any game ranks are not confirmed" do
      @game_rank1.update_attributes(:confirmed_at => nil)
      @game.confirmed?.wont_equal true
    end
  end
end
