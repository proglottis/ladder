require "test_helper"

describe TournamentJoiner do

  describe "#join" do
    before do
      @tournament = create(:started_tournament)
      @user = create(:user)
    end

    it "creates a player and rating" do
      player = TournamentJoiner.new(@tournament, @user).join

      player.tournament.must_equal @tournament
      player.user.must_equal @user
      player.ratings.count.must_equal 1
    end

    it "enables a player if they were already joined" do
      player = create(:player, tournament: @tournament, user: @user, end_at: Time.zone.now, position: 1)

      new_player = TournamentJoiner.new(@tournament, @user).join

      new_player.must_equal player
      new_player.end_at.must_equal nil
      new_player.position.must_equal nil
    end
  end
end
