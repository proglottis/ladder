require 'test_helper'

class UnconfirmedGameNotificationJobTest < ActiveJob::TestCase
  def create_game
    @game = create(:unconfirmed_game)
    @game_rank1 = create(:game_rank, :game => @game, :player => create(:player), :position => 1)
  end

  test "sends an email for unconfirmed games that are older than the beginning of today" do
    perform_enqueued_jobs do
      travel_to(Time.new(2016, 1, 1))
      create_game

      travel_to(Time.new(2016, 1, 22))
      UnconfirmedGameNotificationJob.perform_now

      assert_equal ActionMailer::Base.deliveries.length, 1
    end
  end

  test "wont send an email for unconfirmed games created today" do
    perform_enqueued_jobs do
      create_game

      UnconfirmedGameNotificationJob.perform_now

      assert_equal ActionMailer::Base.deliveries.length, 0
    end
  end
end
