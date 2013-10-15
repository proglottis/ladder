class CreateInviteRequests < ActiveRecord::Migration
  def change
    create_table :invite_requests do |t|
      t.belongs_to :tournament, :null => false
      t.belongs_to :user, :null => false
      t.belongs_to :invite

      t.timestamps
    end
    add_index :invite_requests, [:tournament_id, :user_id], :unique => true
  end
end
