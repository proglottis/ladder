class AddPlayerIdToGameRanks < ActiveRecord::Migration
  def change
    add_column :game_ranks, :player_id, :integer
    add_index :game_ranks, [:game_id, :player_id], unique: true
  end
end
