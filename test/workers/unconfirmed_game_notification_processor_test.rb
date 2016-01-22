require "test_helper"

describe UnconfirmedGameNotificationProcessor do
  def create_game
    @game = create(:unconfirmed_game)
    @game_rank1 = create(:game_rank, :game => @game, :player => create(:player), :position => 1)
    @game.reload
  end

  describe ".perform" do
    it "sends an email for unconfirmed games that are older than the beginning of today" do
      travel_to(Time.new(2016, 1, 1))
      create_game

      travel_to(Time.new(2016, 1, 22))
      UnconfirmedGameNotificationProcessor.perform

      ActionMailer::Base.deliveries.length.must_equal 1
    end

    it "won't send an email for unconfirmed games created today" do
      create_game

      UnconfirmedGameNotificationProcessor.perform

      ActionMailer::Base.deliveries.length.must_equal 0
    end
  end
end
