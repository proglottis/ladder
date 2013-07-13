class ChangePlayerIdNullOnRatings < ActiveRecord::Migration
  def change
    change_column_null :ratings, :player_id, false
  end
end
