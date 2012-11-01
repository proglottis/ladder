class ChangePreferredServiceIdToNullOnUsers < ActiveRecord::Migration
  def up
    change_column :users, :preferred_service_id, :integer, :null => true
  end

  def down
    change_column :users, :preferred_service_id, :integer, :null => false
  end
end
