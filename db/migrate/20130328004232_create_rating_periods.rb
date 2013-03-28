class CreateRatingPeriods < ActiveRecord::Migration
  def change
    create_table :rating_periods do |t|
      t.belongs_to :tournament, :null => false
      t.datetime :period_at,    :null => false

      t.timestamps
    end
    add_index :rating_periods, :tournament_id
    add_index :rating_periods, :period_at
  end
end
