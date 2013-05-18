class ActivityFeed
  def initialize(user)
    @user = user
  end

  def between_dates(start_at, end_at)
    games = Game.where(:updated_at => start_at..end_at).
      with_participant(@user).
      includes(:tournament, :game_ranks => :user)
    challenges = Challenge.where(:updated_at => start_at..end_at).
      where('defender_id = ? OR challenger_id = ?', @user.id, @user.id).
      includes(:tournament, :defender, :challenger)

    (games | challenges).sort_by(&:updated_at).reverse!
  end

end
