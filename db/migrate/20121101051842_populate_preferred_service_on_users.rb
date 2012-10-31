class PopulatePreferredServiceOnUsers < ActiveRecord::Migration
  def up
    User.where(:preferred_service_id => nil).each do |user|
      user.update_attributes :preferred_service => user.services.first
    end
  end

  def down
  end
end
