require "test_helper"

describe Streak do
  describe ".eligible?" do
    it "returns true if last 3 positions are same" do
      streak = Streak.new [1, 2, 2, 2]
      streak.eligible?.must_equal true
    end

    it "returns false if last 3 positions are not the same" do
      streak = Streak.new [1, 2, 2, 1]
      streak.eligible?.must_equal false
    end

    it "returns false if there are less than 3 positions" do
      streak = Streak.new [1, 1]
      streak.eligible?.must_equal false
    end
  end

  describe ".winning?" do
    it "returns true if last 3 positions are 1" do
      streak = Streak.new [1, 1, 1]
      streak.winning?.must_equal true
    end

    it "returns false if any of the last 3 positions is not 1" do
      streak = Streak.new [1, 2, 1]
      streak.winning?.must_equal false
    end

    it "returns false if not eligible" do
      streak = Streak.new [1, 1]
      streak.winning?.must_equal false
    end
  end

  describe ".lenght" do
    it "counts how many of the last positions are same" do
      streak = Streak.new [1, 2, 2, 2]
      streak.lenght.must_equal 3

      streak = Streak.new [1, 2, 2, 1]
      streak.lenght.must_equal 1

      streak = Streak.new [2, 2, 2, 2]
      streak.lenght.must_equal 4
    end
  end
end
