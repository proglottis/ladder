class Rating < ApplicationRecord
  belongs_to :rating_period
  belongs_to :player

  has_one :user, :through => :player

  validates_presence_of :rating_period_id, :player_id
  validates_uniqueness_of :player_id, :scope => :rating_period_id

  def self.with_defaults
    where(:rating => Glicko2::DEFAULT_GLICKO_RATING,
          :rating_deviation => Glicko2::DEFAULT_GLICKO_RATING_DEVIATION,
          :volatility => Glicko2::DEFAULT_VOLATILITY)
  end

  def self.active(at = Time.zone.now)
    joins(:player).merge(Player.active(at))
  end

  def self.active_by_position
    active.order('players.position ASC')
  end

  def self.for_game(game)
    ratings = arel_table
    players = Player.arel_table
    rating_periods = RatingPeriod.arel_table
    games = Game.arel_table
    game_ranks = GameRank.arel_table
    joins = ratings.
      join(players).on(ratings[:player_id].eq(players[:id])).
      join(rating_periods).on(rating_periods[:id].eq(ratings[:rating_period_id])).
      join(games).on(rating_periods[:tournament_id].eq(games[:tournament_id])).
      join(game_ranks).on(games[:id].eq(game_ranks[:game_id]).and(players[:id].eq(game_ranks[:player_id])))
    joins(joins.join_sources).where(games[:id].eq(game.id)).
      select('ratings.*, game_ranks.position')
  end

  def low_rank
    rating - 2.0 * rating_deviation
  end

  def high_rank
    rating + 2.0 * rating_deviation
  end

  def position
    read_attribute(:position).try(:to_i)
  end

  def period_at
    (read_attribute(:period_at) || rating_period.period_at).to_time
  end

  def defending_challenge?
    rating_period.tournament.games.defender(user).any?
  end

  def glicko2_rating
    @glicko2_rating ||= Glicko2::Rating.from_glicko_rating(rating, rating_deviation, volatility)
  end

  def chance_to_beat(other)
    _, e = other.glicko2_rating.gravity_expected_score(glicko2_rating.mean)
    e
  end
end
