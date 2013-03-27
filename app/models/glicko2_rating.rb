class Glicko2Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament

  validates_presence_of :user_id, :tournament_id

  def self.with_defaults
    where(:rating => Glicko2::DEFAULT_GLICKO_RATING,
          :rating_deviation => Glicko2::DEFAULT_GLICKO_RATING_DEVIATION,
          :volatility => Glicko2::DEFAULT_VOLATILITY)
  end

  def self.by_rank
    order('(glicko2_ratings.rating - 2.0 * glicko2_ratings.rating_deviation) DESC')
  end

  def self.for_game(game)
    ratings = arel_table
    games = Game.arel_table
    game_ranks = GameRank.arel_table
    joins = ratings.join(games).on(ratings[:tournament_id].eq(games[:tournament_id])).
      join(game_ranks).on(games[:id].eq(game_ranks[:game_id]).and(ratings[:user_id].eq(game_ranks[:user_id])))
    joins(joins.join_sql).where(ratings[:tournament_id].eq(games[:tournament_id]).and(games[:id].eq(game.id))).
      select('glicko2_ratings.*, game_ranks.position')
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

  def challenge
    tournament.challenges.active.detect { |challenge| challenge.defender_id == user_id }
  end
end
