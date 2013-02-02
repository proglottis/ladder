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
        time = Time.zone.now
        game = Game.new(:tournament => challenge.tournament, :owner => challenge.challenger, :confirmed_at => time)
        game.game_ranks.build(:user => challenge.challenger, :position => 1, :confirmed_at => time)
        game.game_ranks.build(:user => challenge.defender, :position => 2, :confirmed_at => time)
        game.save!
        challenge.update_attribute(:game, game)
      end
    end
  end
end
