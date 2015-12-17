require "test_helper"

describe InviteAcceptor do
  describe "#accept" do
    before do
      @tournament = create(:started_tournament)
      @invite = create(:invite, tournament: @tournament)
      @user = create(:user)
    end

    it "sets the invite to the user and joins the user" do
      InviteAcceptor.new(@invite, @user).accept
      @invite.reload.user.must_equal @user
      @user.players.count.must_equal 1
      @user.players.first.tournament.must_equal @tournament
    end
  end
end
