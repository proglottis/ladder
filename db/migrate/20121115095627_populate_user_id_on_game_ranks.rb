class PopulateUserIdOnGameRanks < ActiveRecord::Migration
  def up
    GameRank.includes(:rank).each do |game_rank|
      game_rank.update_attributes(:user_id => game_rank.rank.user_id)
    end
  end

  def down
  end
end
