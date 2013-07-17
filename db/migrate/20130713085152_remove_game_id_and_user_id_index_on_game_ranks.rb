class RemoveGameIdAndUserIdIndexOnGameRanks < ActiveRecord::Migration
  def up
    remove_index :game_ranks, [:game_id, :user_id]
  end

  def down
    add_index :game_ranks, [:game_id, :user_id], unique: true
  end
end
