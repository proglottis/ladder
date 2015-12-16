class BackpopulateCompletedAtOnInviteRequests < ActiveRecord::Migration
  def up
    InviteRequest.find_each do |request|
      request.update_attributes!(completed_at: Time.zone.now) if request.invite_id
    end
  end

  def down
  end
end
