class ActivityFeed
  def initialize(start_at, end_at)
    @start_at = start_at
    @end_at = end_at
  end

  def for_user(user, *viewing_users)
    viewing_users << user
    tournaments = Tournament.with_rated_user(*viewing_users)
    games = Game.where(:updated_at => @start_at..@end_at).
      where(:tournament_id => tournaments.map(&:id)).
      participant(user).
      includes(:tournament, :game_ranks => :user)
    challenges = Challenge.where(:updated_at => @start_at..@end_at).
      where(:tournament_id => tournaments.map(&:id)).
      where('defender_id = ? OR challenger_id = ?', user.id, user.id).
      includes(:tournament, :defender, :challenger)

    (games | challenges).sort_by(&:updated_at).reverse!
  end

end
