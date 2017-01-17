class ChallengeProcessorJob < ApplicationJob
  queue_as :default

  def perform
    expired_at = Time.zone.now.beginning_of_day

    Game.challenged.where("games.created_at < ?", expired_at - 1.week).readonly(false).find_each do |game|
      game.expire_challenge!
    end
  end
end
