class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.belongs_to :user
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
