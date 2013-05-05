class RemoveMessageFromChallenges < ActiveRecord::Migration
  def up
    remove_column :challenges, :message
  end

  def down
  end
end
