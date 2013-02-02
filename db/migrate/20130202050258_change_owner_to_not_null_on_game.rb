class ChangeOwnerToNotNullOnGame < ActiveRecord::Migration
  def up
    change_column :games, :owner_id, :integer, :null => false
  end

  def down
    change_column :games, :owner_id, :integer
  end
end
