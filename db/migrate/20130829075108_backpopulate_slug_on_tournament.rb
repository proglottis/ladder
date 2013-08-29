class BackpopulateSlugOnTournament < ActiveRecord::Migration
  def up
    Tournament.find_each(&:save)
  end

  def down
  end
end
