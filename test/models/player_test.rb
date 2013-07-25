require "test_helper"

describe Player do
  before do
    @player = create(:player)
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
  end
end
