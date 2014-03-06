require "test_helper"

describe Player do
  before do
    @player = create(:player)
  end

  describe ".active" do
    it "finds players with end date" do
      player = create(:player, :end_at => 1.week.from_now)
      Player.active.must_include player
    end

    it "finds players without end date" do
      player = create(:player, :end_at => nil)
      Player.active.must_include player
    end

    it "wont find players outside of range" do
      player = create(:player, :end_at => 1.day.ago)
      Player.active.wont_include player
    end

    it "finds players with exclusive end date" do
      end_date = Time.zone.now
      player = create(:player, :end_at => end_date)
      Player.active(end_date).wont_include player
    end
  end

  describe "#streak?" do
    it "must be true if winning count is 3 or more" do
      @player.winning_streak_count = 3
      @player.losing_streak_count = 0
      @player.streak?.must_equal true
    end

    it "must be true if losing count is 3 or more" do
      @player.winning_streak_count = 0
      @player.losing_streak_count = 3
      @player.streak?.must_equal true
    end

    it "wont be true if winning and loosing count is less than 3" do
      @player.winning_streak_count = 0
      @player.losing_streak_count = 0
      @player.streak?.must_equal false
    end
  end

  describe "#winning_streak?" do
    it "must be true if count is 3 or more" do
      @player.winning_streak_count = 3
      @player.winning_streak?.must_equal true
    end

    it "must be false if count is less than 3" do
      @player.winning_streak_count = 0
      @player.winning_streak?.must_equal false
    end

    it "must be false if losing count is more than 1" do
      @player.losing_streak_count = 3
      @player.winning_streak_count = 3
      @player.winning_streak?.must_equal false
    end
  end

  describe "#losing_streak?" do
    it "must be true if count is 3 or more" do
      @player.losing_streak_count = 3
      @player.losing_streak?.must_equal true
    end

    it "must be false if count is less than 3" do
      @player.losing_streak_count = 0
      @player.losing_streak?.must_equal false
    end

    it "must be false if winning count is more than 1" do
      @player.losing_streak_count = 3
      @player.winning_streak_count = 3
      @player.losing_streak?.must_equal false
    end
  end
end
