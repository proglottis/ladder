class AddConfirmedAtToGame < ActiveRecord::Migration
  def change
    add_column :games, :confirmed_at, :datetime
  end
end
