class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references :championship, index: true, null: false
      t.integer :bracket, null: false
      t.integer :player1_id
      t.integer :player2_id
      t.references :game, index: true
      t.integer :winners_match_id
      t.integer :losers_match_id

      t.timestamps
    end
  end
end
