class TournamentJoiner
  def initialize(tournament, user)
    @tournament = tournament
    @user = user
  end

  def join
    @tournament.with_lock do
      rating_period = @tournament.current_rating_period
      player = @tournament.players.create!(:user => @user)
      rating_period.ratings.with_defaults.create!(:player => player)
      player
    end
  end
end
