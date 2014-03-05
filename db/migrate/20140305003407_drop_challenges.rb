class DropChallenges < ActiveRecord::Migration
  def up
    Comment.where(commentable_type: 'Challenge').destroy_all
    drop_table :challenges
  end

  def down
    # There's no turning back!
  end
end
