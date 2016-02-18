class AddGameUnconfirmedEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :game_unconfirmed_email, :boolean, :null => false, :default => true
  end
end
