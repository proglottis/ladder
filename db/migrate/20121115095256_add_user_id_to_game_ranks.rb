class AddUserIdToGameRanks < ActiveRecord::Migration
  def change
    add_column :game_ranks, :user_id, :integer
    add_index :game_ranks, :user_id
  end
end
