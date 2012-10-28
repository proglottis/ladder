class AddOwnerToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :owner_id, :integer, :null => false
    add_index :invites, :owner_id
  end
end
