class UpdateTrueskillRanks < ActiveRecord::Migration
  def up
    Rank.update_all :mu => 25.0, :sigma => 25.0 / 3.0
    Game.record_timestamps = false
    GameRank.includes(:game).order('game_ranks.confirmed_at ASC').each do |game_rank|
      game_rank.game.update_attributes! :updated_at => game_rank.confirmed_at if game_rank.confirmed_at
    end
    Game.record_timestamps = true
    Game.order('games.updated_at ASC').each do |game|
      game.process_trueskill if game.confirmed?
    end
  end

  def down
  end
end
