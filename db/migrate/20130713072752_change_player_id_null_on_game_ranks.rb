class ChangePlayerIdNullOnGameRanks < ActiveRecord::Migration
  def up
    change_column_null :game_ranks, :player_id, false
  end

  def down
    change_column_null :game_ranks, :player_id, true
  end
end
