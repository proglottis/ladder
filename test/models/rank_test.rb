require "minitest_helper"

describe Rank do
  describe "#rank" do
    let(:rank) { FactoryGirl.create(:rank) }

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
