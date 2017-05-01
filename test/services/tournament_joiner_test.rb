require "test_helper"

describe TournamentJoiner do

  describe "#join" do
    before do
      @tournament = create(:started_tournament)
      @user = create(:user)
    end

    it "creates a player and rating" do
      player = TournamentJoiner.new(@tournament, @user).join

      assert_equal @tournament, player.tournament
      assert_equal @user, player.user
      assert_equal 1, player.ratings.count
    end

    it "enables a player if they were already joined" do
      player = create(:player, tournament: @tournament, user: @user, end_at: Time.zone.now, position: 1)

      new_player = TournamentJoiner.new(@tournament, @user).join

      assert_equal player, new_player
      assert_nil new_player.end_at
      assert_nil new_player.position
    end
  end
end
