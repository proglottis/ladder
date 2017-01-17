require 'test_helper'

class ChallengeProcessorJobTest < ActiveJob::TestCase
  test "expires challenged games that are older than 1 week from the beginning of the day" do
    travel_to(Time.new(2010, 1, 1))
    game = create(:challenge_game)

    travel_to(Time.new(2010, 1, 10))
    ChallengeProcessorJob.perform_now

    assert game.reload.confirmed?
  end

  test "wont expire challenged games that are newer" do
    game = create(:challenge_game)
    ChallengeProcessorJob.perform_now
    assert game.reload.challenged?
  end

  test "wont expire non-challenge games" do
    travel_to(Time.new(2010, 1, 1))
    game = create(:unconfirmed_game)

    travel_to(Time.new(2010, 1, 10))
    ChallengeProcessorJob.perform_now

    assert game.reload.unconfirmed?
  end
end
