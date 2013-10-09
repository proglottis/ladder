class BackpopulateChallengedGameEvents < ActiveRecord::Migration
  def up
    GameEvent.record_timestamps = false
    Challenge.record_timestamps = false
    Game.record_timestamps = false
    Challenge.transaction do
      Challenge.find_each do |challenge|
        if challenge.game
          challenge.game.events.destroy_all
          challenge.game.events.create! state: "challenged", created_at: challenge.created_at, updated_at: challenge.created_at
          challenge.game.events.create! state: "confirmed", created_at: challenge.game.created_at, updated_at: challenge.game.created_at
        else
          game = Game.build tournament: challenge.tournament, created_at: challenge.created_at, updated_at: challenge.created_at
          game.states.build :state => "challenged"
          game.owner = challenge.challenger
          game.game_ranks.build user: challenge.challenger, created_at: challenge.created_at, updated_at: challenge.created_at
          game.game_ranks.build user: challenge.defender, created_at: challenge.created_at, updated_at: challenge.created_at
          game.save!
        end
      end
    end
    GameEvent.record_timestamps = true
    Challenge.record_timestamps = true
    Game.record_timestamps = true
  end

  def down
    GameEvent.where(state: "challenged").destroy_all
  end
end
