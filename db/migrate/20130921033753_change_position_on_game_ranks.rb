class ChangePositionOnGameRanks < ActiveRecord::Migration
  def up
    change_column :game_ranks, :position, :integer, null: true
  end

  def down
    change_column :game_ranks, :position, :integer, null: false
  end
end
