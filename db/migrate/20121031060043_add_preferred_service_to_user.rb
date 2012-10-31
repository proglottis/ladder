class AddPreferredServiceToUser < ActiveRecord::Migration
  def change
    add_column :users, :preferred_service_id, :integer
    add_index :users, :preferred_service_id
  end
end
