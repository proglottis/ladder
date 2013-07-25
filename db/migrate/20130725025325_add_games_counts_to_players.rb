class AddGamesCountsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :winning_streak_count, :integer, default: 0, null: false
    add_column :players, :losing_streak_count, :integer, default: 0, null: false
  end
end
