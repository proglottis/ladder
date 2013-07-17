class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :user, index: true, null: false
      t.references :tournament, index: true, null: false

      t.timestamps
    end
    add_index :players, [:user_id, :tournament_id], unique: true
  end
end
