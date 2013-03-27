require "test_helper"

describe Game do
  before do
    @game = create(:game)
    @user1 = create(:user)
    @user2 = create(:user)
    @game_rank1 = create(:game_rank, :game => @game, :user => @user1, :position => 1)
    @game_rank2 = create(:game_rank, :game => @game, :user => @user2, :position => 2)
  end

  describe ".destroy" do
    it "must destroy descendent game ranks" do
      @game.destroy
      GameRank.where(:game_id => @game.id).count.must_equal 0
    end
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

    it "must match with both participants" do
      Game.with_participant(@user1, @user2).must_include @game
    end

    it "wont match with a single nonparticipant" do
      @user = create(:user)
      Game.with_participant(@user1, @user).wont_include @game
    end
  end

  describe "#confirm_user" do
    it "must confirm the users rank" do
      @game.confirm_user(@user1)
      @game_rank1.reload.confirmed?.must_equal true
    end

    it "wont confirm other users rank" do
      @game.confirm_user(@user1)
      @game_rank2.reload.confirmed?.wont_equal true
    end

    it "must return true when game is confirmed" do
      @game.confirm_user(@user1).wont_equal true
      @game.confirm_user(@user2).must_equal true
    end
  end

  describe "#confirmed?" do
    it "must be true when confirmed_at is not nil" do
      @game.confirmed_at = Time.zone.now
      @game.confirmed?.must_equal true
    end

    it "wont be true when confirmed_at is nil" do
      @game.confirmed_at = nil
      @game.confirmed?.wont_equal true
    end
  end
end
