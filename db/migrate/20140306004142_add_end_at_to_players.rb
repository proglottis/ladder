class AddEndAtToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :end_at, :datetime
  end
end
