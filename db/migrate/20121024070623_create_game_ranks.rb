class CreateGameRanks < ActiveRecord::Migration
  def change
    create_table :game_ranks do |t|
      t.belongs_to :rank, :null => false
      t.belongs_to :game, :null => false
      t.integer :position, :null => false
      t.datetime :confirmed_at

      t.timestamps
    end
    add_index :game_ranks, :rank_id
    add_index :game_ranks, :game_id
  end
end
