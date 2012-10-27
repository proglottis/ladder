require "minitest_helper"

describe Game do
  before do
    @game = create(:game)
    @game_rank1 = create(:game_rank, :game => @game, :confirmed_at => Time.now, :position => 1)
    @game_rank2 = create(:game_rank, :game => @game, :confirmed_at => Time.now, :position => 2)
  end

  describe ".with_participant" do
    it "must match participant" do
      Game.with_participant(@game_rank1.rank.user).must_include @game
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

  describe "#process" do
    it "must update ranks" do
      @game.process
      @game_rank1.rank.reload.rank.wont_be_close_to 0.0
      @game_rank2.rank.reload.rank.wont_be_close_to 0.0
    end
  end
end
