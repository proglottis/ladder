class Rating < ActiveRecord::Base
  belongs_to :rating_period
  belongs_to :user

  validates_presence_of :rating_period_id, :user_id
  validates_uniqueness_of :user_id, :scope => :rating_period_id

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

  def position
    read_attribute(:position).to_i
  end
end
