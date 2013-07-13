class BackpopulatePlayerIdOnGameRanks < ActiveRecord::Migration
  def up
    Tournament.find_each do |tournament|
      tournament.game_ranks.find_each do |game_rank|
        player = tournament.players.find_by! user_id: game_rank.user_id
        game_rank.update_attributes! player_id: player.id
      end
    end
  end

  def down
    GameRank.update_all player_id: nil
  end
end
