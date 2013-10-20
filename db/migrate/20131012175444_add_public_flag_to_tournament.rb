class AddPublicFlagToTournament < ActiveRecord::Migration
  def change
   add_column :tournaments, :public, :boolean, :null => false, :default => false
   add_index :tournaments, :public
  end
end
