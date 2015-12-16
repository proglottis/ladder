class AddCompletedAtToInviteRequests < ActiveRecord::Migration
  def change
    add_column :invite_requests, :completed_at, :datetime
  end
end
