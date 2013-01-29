class DropEloRatings < ActiveRecord::Migration
  def up
    drop_table :elo_ratings
  end

  def down
  end
end
