class AddGameConfirmedEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :game_confirmed_email, :boolean, :null => false, :default => true
  end
end
