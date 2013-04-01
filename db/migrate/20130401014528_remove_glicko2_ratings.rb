class RemoveGlicko2Ratings < ActiveRecord::Migration
  def up
    drop_table :glicko2_ratings
  end

  def down
  end
end
