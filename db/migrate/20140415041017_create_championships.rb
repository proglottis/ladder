class CreateChampionships < ActiveRecord::Migration
  def change
    create_table :championships do |t|
      t.references :tournament, index: true, null: false
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
