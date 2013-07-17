class BackpopulatePlayers < ActiveRecord::Migration
  def up
    Tournament.find_each do |tournament|
      tournament.current_rating_period.ratings.each do |rating|
        tournament.players.create! :user_id => rating.user_id
      end
    end
  end

  def down
    Player.destroy_all
  end
end
