class BackpopulatePlayers < ActiveRecord::Migration
  def up
    Tournament.find_each do |tournament|
      tournament.users.uniq.each do |user|
        tournament.players.create! :user => user
      end
    end
  end

  def down
    Player.destroy_all
  end
end
