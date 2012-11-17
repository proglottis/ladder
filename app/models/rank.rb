class Rank < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament

  validates_presence_of :user_id, :tournament_id

  def self.with_defaults
    where(:mu => 25.0, :sigma => 25.0 / 3.0)
  end

  def self.for_game(game)
    ranks = arel_table
    games = Game.arel_table
    game_ranks = GameRank.arel_table
    joins = ranks.join(games).on(ranks[:tournament_id].eq(games[:tournament_id])).
      join(game_ranks).on(games[:id].eq(game_ranks[:game_id]).and(ranks[:user_id].eq(game_ranks[:user_id])))
    joins(joins.join_sql).where(ranks[:tournament_id].eq(games[:tournament_id]).and(games[:id].eq(game.id))).
      select('ranks.*, game_ranks.position')
  end

  def self.by_rank
    order('(ranks.mu - 3.0 * ranks.sigma) DESC')
  end

  def rank
    mu - 3.0 * sigma
  end

  def position
    read_attribute(:position).try(:to_i)
  end
end
