class GameEvent < ActiveRecord::Base
  belongs_to :game

  validates_inclusion_of :state, in: Game::STATES

  def self.latest_state(state)
    where("game_events.id IN (SELECT MAX(id) FROM game_events GROUP BY game_id) AND state = ?", state)
  end
end
