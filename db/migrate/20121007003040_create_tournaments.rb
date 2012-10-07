class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.string :name, :null => false
      t.references :owner, :null => false

      t.timestamps
    end
  end
end
