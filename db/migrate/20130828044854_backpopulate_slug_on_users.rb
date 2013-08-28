class BackpopulateSlugOnUsers < ActiveRecord::Migration
  def up
    User.find_each(&:save)
  end

  def down
  end
end
