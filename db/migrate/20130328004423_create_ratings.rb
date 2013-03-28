class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.belongs_to :rating_period, :null => false
      t.belongs_to :user,          :null => false
      t.decimal :rating,           :null => false, :precision => 38, :scale => 10
      t.decimal :rating_deviation, :null => false, :precision => 38, :scale => 10
      t.decimal :volatility,       :null => false, :precision => 38, :scale => 10

      t.timestamps
    end
    add_index :ratings, :rating_period_id
    add_index :ratings, :user_id
  end
end
