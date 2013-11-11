class ChallengeProcessor
  def initialize(expired_at)
    @expired_at = expired_at
  end

  def self.perform
    processor = ChallengeProcessor.new(Time.zone.now.beginning_of_day)
    processor.process
  end

  def process
    Game.challenged.where("games.created_at < ?", @expired_at - 1.week).find_each do |game|
      game.expire_challenge!
    end
  end
end
