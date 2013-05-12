class ChallengeProcessor
  def initialize(expired_at)
    @expired_at = expired_at
  end

  def self.perform
    processor = ChallengeProcessor.new(Time.zone.now.beginning_of_day)
    processor.process
  end

  def process
    Challenge.active.where("expires_at < ?", @expired_at).find_each do |challenge|
      challenge.with_lock do
        game = challenge.build_default_game
        game.save!
        challenge.update_attribute(:game, game)
      end
    end
  end
end
