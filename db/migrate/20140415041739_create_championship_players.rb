class CreateChampionshipPlayers < ActiveRecord::Migration
  def change
    create_table :championship_players do |t|
      t.references :championship, index: true, null: false
      t.references :player, index: true, null: false

      t.timestamps
    end

    add_index :championship_players, [:championship_id, :player_id], unique: true
  end
end
