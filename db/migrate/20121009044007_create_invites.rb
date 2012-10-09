class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.belongs_to :user
      t.belongs_to :tournament
      t.string :code, :null => false
      t.string :email, :null => false
      t.datetime :expires_at, :null => false

      t.timestamps
    end
    add_index :invites, :user_id
    add_index :invites, :tournament_id
    add_index :invites, :code
  end
end
