class Rating < ActiveRecord::Base
  belongs_to :rating_period
  belongs_to :user

  validates_presence_of :rating_period_id, :user_id
  validates_uniqueness_of :user_id, :scope => :rating_period_id

  def self.with_defaults
    where(:rating => Glicko2::DEFAULT_GLICKO_RATING,
          :rating_deviation => Glicko2::DEFAULT_GLICKO_RATING_DEVIATION,
          :volatility => Glicko2::DEFAULT_VOLATILITY)
  end

  def self.by_rank
    order('(ratings.rating - 2.0 * ratings.rating_deviation) DESC')
  end

  def self.for_game(game)
    ratings = arel_table
    rating_periods = RatingPeriod.arel_table
    games = Game.arel_table
    game_ranks = GameRank.arel_table
    joins = ratings.
      join(rating_periods).on(rating_periods[:id].eq(ratings[:rating_period_id])).
      join(games).on(rating_periods[:tournament_id].eq(games[:tournament_id])).
      join(game_ranks).on(games[:id].eq(game_ranks[:game_id]).and(ratings[:user_id].eq(game_ranks[:user_id])))
    joins(joins.join_sql).where(games[:id].eq(game.id)).
      select('ratings.*, game_ranks.position')
  end

  def self.with_defending_tournament
    ratings = arel_table
    challenges = Challenge.arel_table
    joins = ratings.join(challenges, Arel::Nodes::OuterJoin).on(
      ratings[:user_id].eq(challenges[:defender_id]).
      and(challenges[:game_id].eq(nil)))
    joins(joins.join_sql).
      select('ratings.*, challenges.id as defending_challenge_id')
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
    if has_attribute? :defending_challenge_id
      read_attribute(:defending_challenge_id).present?
    else
      rating_period.tournament.challenges.active.defending(user).present?
    end
  end
end
