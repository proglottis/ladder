class BackpopulatePositionOnPlayers < ActiveRecord::Migration
  def up
    Tournament.find_each do |tournament|
      tournament.current_rating_period.update_player_positions!
    end
  end

  def down
    Player.find_each do |player|
      player.update_attributes!(:position => nil)
    end
  end
end
