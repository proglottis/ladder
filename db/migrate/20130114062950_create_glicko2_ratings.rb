class CreateGlicko2Ratings < ActiveRecord::Migration
  def change
    create_table :glicko2_ratings do |t|
      t.belongs_to :user, :null => false
      t.belongs_to :tournament, :null => false
      t.decimal :rating, :precision => 38, :scale => 10, :null => false
      t.decimal :rating_deviation, :precision => 38, :scale => 10, :null => false
      t.decimal :volatility, :precision => 38, :scale => 10, :null => false

      t.timestamps
    end
  end
end
