class ChangeUserIdToNotNullOnGameRanks < ActiveRecord::Migration
  def up
    change_column :game_ranks, :user_id, :integer, :null => false
  end

  def down
    change_column :game_ranks, :user_id, :integer
  end
end
