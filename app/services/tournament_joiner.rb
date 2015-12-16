class TournamentJoiner
  def initialize(tournament, user)
    @tournament = tournament
    @user = user
  end

  def join
    @tournament.with_lock do
      rating_period = @tournament.current_rating_period
      if player = @tournament.players.find_by(user_id: @user.id)
        player.update_attributes! end_at: nil, position: nil
      else
        player = @tournament.players.create!(:user => @user)
        rating_period.ratings.with_defaults.create!(:player => player)
      end
      player
    end
  end
end
