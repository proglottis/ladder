class CreateGameEvents < ActiveRecord::Migration
  def change
    create_table :game_events do |t|
      t.belongs_to :game, index: true
      t.string :state, null: false

      t.timestamps
    end
  end
end
