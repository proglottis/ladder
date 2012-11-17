class RemoveRankIdFromGameRanks < ActiveRecord::Migration
  def up
    remove_index :game_ranks, :rank_id
    remove_column :game_ranks, :rank_id
  end

  def down
    # Screwed, restore backup!
  end
end
