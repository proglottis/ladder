class BackpopulateGameEvents < ActiveRecord::Migration
  def up
    GameEvent.record_timestamps = false
    Game.find_each do |game|
      game.events.create! state: "unconfirmed", created_at: game.created_at, updated_at: game.created_at
      if game.confirmed_at
        game.events.create! state: "confirmed", created_at: game.confirmed_at, updated_at: game.confirmed_at
      end
    end
    GameEvent.record_timestamps = true
  end

  def down
    GameEvent.delete_all
  end
end
