class RemoveUserIdFromGameRanks < ActiveRecord::Migration
  def up
    remove_column :game_ranks, :user_id
  end

  def down
    # no turning back!
  end
end
