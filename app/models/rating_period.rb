class RatingPeriod < ActiveRecord::Base
  belongs_to :tournament

  has_many :ratings, :dependent => :destroy

  validates_presence_of :tournament_id, :period_at
  validates_uniqueness_of :period_at, :scope => :tournament_id

  def previous_rating_period
    @previous_rating_period ||= tournament.rating_periods.
      where('rating_periods.period_at < ?', period_at).
      order('rating_periods.period_at DESC').first
  end

  def games
    tournament.games.confirmed_between(previous_rating_period.period_at, period_at)
  end

  def process!
    return unless previous_rating_period
    with_lock do
      period = glicko2_rating_period_with_games
      new_period = period.generate_next
      new_period.players.each do |player|
        player.update_obj
        rating = ratings.find_or_initialize_by(:player_id => player.obj.player_id)
        rating.user_id = player.obj.user_id
        rating.rating = player.obj.rating
        rating.rating_deviation = player.obj.rating_deviation
        rating.volatility = player.obj.volatility
        rating.save!
      end
    end
  end

  private

  def glicko2_rating_period_with_games
    period = Glicko2::RatingPeriod.from_objs(previous_rating_period.ratings)
    games.each do |game|
      ratings_for_game = previous_rating_period.ratings.for_game(game)
      period.game ratings_for_game, ratings_for_game.map(&:position)
    end
    period
  end
end
