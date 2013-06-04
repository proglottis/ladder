class AddUniqueIndexToGameRanks < ActiveRecord::Migration
  def change
    add_index :game_ranks, [:game_id, :user_id], :unique => true
  end
end
