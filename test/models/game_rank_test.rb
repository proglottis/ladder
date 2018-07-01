require "test_helper"

describe GameRank do
  before do
    @game_rank = create(:game_rank)
    @user = @game_rank.user
  end

  describe ".not_confirmed" do
    it "must match game ranks that are not confirmed" do
      GameRank.not_confirmed.must_include @game_rank
    end

    it "wont match game ranks that are confirmed" do
      @game_rank = create(:game_rank, :confirmed_at => Time.zone.now)
      GameRank.not_confirmed.wont_include @game_rank
    end
  end

  describe ".with_participant" do
    it "must match with participant" do
      GameRank.with_participant(@user).must_include @game_rank
    end

    it "wont match without participant" do
      @user = create(:user)
      GameRank.with_participant(@user).wont_include @game_rank
    end
  end

  describe "#confirm" do
    it "must confirm participant" do
      @game_rank.confirm
      @game_rank.confirmed_at.wont_equal nil
    end

    it "wont reconfirm participant" do
      time = 1.day.ago
      @game_rank = create(:game_rank, :confirmed_at => time)
      @game_rank.confirm
      assert_in_delta @game_rank.confirmed_at, time, 1.second
    end
  end
end
