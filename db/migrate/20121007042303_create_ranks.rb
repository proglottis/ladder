class CreateRanks < ActiveRecord::Migration
  def change
    create_table :ranks do |t|
      t.belongs_to :user, :null => false
      t.belongs_to :tournament, :null => false
      t.decimal :mu, :null => false, :precision => 38, :scale => 5
      t.decimal :sigma, :null => false, :precision => 38, :scale => 5

      t.timestamps
    end
    add_index :ranks, :user_id
    add_index :ranks, :tournament_id
  end
end
