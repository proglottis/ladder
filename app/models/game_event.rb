class GameEvent < ApplicationRecord
  belongs_to :game, touch: true, optional: true

  validates_inclusion_of :state, in: Game::STATES

  def self.latest_state(state)
    where("game_events.id IN (SELECT MAX(id) FROM game_events GROUP BY game_id)").where(:state => state)
  end
end
