require "test_helper"

describe ChallengeProcessor do
  describe ".perform" do
    it "expires challenged games that are older than 1 week from the beginning of the day" do
      travel_to(Time.new(2010, 1, 1))
      game = create(:challenge_game)

      travel_to(Time.new(2010, 1, 10))
      ChallengeProcessor.perform

      game.reload.must_be :confirmed?
    end

    it "wont expire challenged games that are newer" do
      game = create(:challenge_game)
      ChallengeProcessor.perform
      game.reload.must_be :challenged?
    end

    it "wont expire non-challenge games" do
      travel_to(Time.new(2010, 1, 1))
      game = create(:unconfirmed_game)

      travel_to(Time.new(2010, 1, 10))
      ChallengeProcessor.perform

      game.reload.must_be :unconfirmed?
    end
  end
end
