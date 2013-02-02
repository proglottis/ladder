class AddOwnerToGame < ActiveRecord::Migration
  def change
    add_column :games, :owner_id, :integer
    add_index :games, :owner_id
  end
end
