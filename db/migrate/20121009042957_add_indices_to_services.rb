class AddIndicesToServices < ActiveRecord::Migration
  def change
    add_index :services, :user_id
    add_index :services, :provider
    add_index :services, :uid
  end
end
