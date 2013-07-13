class BackpopulatePlayerIdOnRatings < ActiveRecord::Migration
  def up
    Tournament.find_each do |tournament|
      tournament.ratings.find_each do |rating|
        player = tournament.players.find_by! user_id: rating.user_id
        rating.update_attributes! player_id: player.id
      end
    end
  end

  def down
    Rating.update_all player_id: nil
  end
end
