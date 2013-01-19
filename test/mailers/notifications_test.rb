require "minitest_helper"

describe Notifications do
  describe "#game_confirmation" do
    before do
      @game = create(:game)
      @user1 = create(:user)
      @user2 = create(:user)
      @game_rank1 = create(:game_rank, :game => @game, :user => @user1, :position => 1)
      @game_rank2 = create(:game_rank, :game => @game, :user => @user2, :position => 2)
    end

    it "must contain game details" do
      mail = Notifications.game_confirmation @user1, @game
      mail.subject.must_equal "Confirm game"
      mail.to.must_equal [@user1.email]
      mail.body.encoded.must_match @game.tournament.name
      mail.body.encoded.must_match @game.versus
    end
  end
end
