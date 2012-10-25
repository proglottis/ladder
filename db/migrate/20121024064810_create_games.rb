class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.belongs_to :tournament, :null => false

      t.timestamps
    end
    add_index :games, :tournament_id
  end
end
