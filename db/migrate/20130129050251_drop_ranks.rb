class DropRanks < ActiveRecord::Migration
  def up
    drop_table :ranks
  end

  def down
  end
end
