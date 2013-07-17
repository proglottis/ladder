class AddPlayerIdToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :player_id, :integer
    add_index :ratings, [:rating_period_id, :player_id], :unique => true
  end
end
