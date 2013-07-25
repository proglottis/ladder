class ActivityFeed
  def initialize(user, *viewing_users)
    @user = user
    @viewing_users = viewing_users << primary_user
  end

  def between_dates(start_at, end_at)
    tournaments = Tournament.with_rated_user(*@viewing_users)
    games = Game.where(:updated_at => start_at..end_at).
      with_participant(*@viewing_users).
      includes(:tournament, :game_ranks => :user)
    challenges = Challenge.where(:updated_at => start_at..end_at).
      where(:tournament_id => tournaments.map(&:id)).
      where('defender_id = ? OR challenger_id = ?', @user.id, @user.id).
      includes(:tournament, :defender, :challenger)

    (games | challenges).sort_by(&:updated_at).reverse!
  end

end
