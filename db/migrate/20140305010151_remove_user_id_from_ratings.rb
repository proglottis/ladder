class RemoveUserIdFromRatings < ActiveRecord::Migration
  def up
    remove_column :ratings, :user_id
  end

  def down
    # Sorry
  end
end
