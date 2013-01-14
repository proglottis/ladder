class UpdateConfirmedAtForGames < ActiveRecord::Migration
  def up
    Game.record_timestamps = false
    Game.find_each do |game|
      if game.game_ranks.not_confirmed.count < 1
        game.update_attributes!(:confirmed_at => game.game_ranks.order('confirmed_at DESC').first.confirmed_at)
      end
    end
    Game.record_timestamps = true
  end

  def down
  end
end
