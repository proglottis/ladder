class Challenge < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :challenger, :class_name => 'User'
  belongs_to :defender, :class_name => 'User'
  belongs_to :game

  before_validation :generate_expires_at

  validate :not_already_challenged

  attr_accessor :response

  def self.active
    where(:game_id => nil)
  end

  def self.defending(user)
    where(:defender_id => user)
  end

  def self.challenging(user)
    where(:challenger_id => user)
  end

  def active?
    game_id.nil?
  end

  def processed_at
    expires_at.tomorrow.midnight
  end

  def respond!
    return if response.blank?
    with_lock do
      game = Game.new(:tournament => tournament, :owner => challenger)
      case response
      when 'won'
        game.game_ranks.build(:user => defender, :position => 1, :confirmed_at => Time.zone.now)
        game.game_ranks.build(:user => challenger, :position => 2)
        game.save!
        update_attribute(:game, game)
        Notifications.game_confirmation(challenger, game).deliver
      when 'lost'
        game.game_ranks.build(:user => defender, :position => 2, :confirmed_at => Time.zone.now)
        game.game_ranks.build(:user => challenger, :position => 1)
        game.save!
        update_attribute(:game, game)
        Notifications.game_confirmation(challenger, game).deliver
      end
    end
  end

  private

  def generate_expires_at
    self.expires_at = 7.days.from_now
  end

  def not_already_challenged
    if self.class.active.defending(defender).where(:tournament_id => tournament_id).length > 0
      errors.add(:defender, 'already challenged')
    end
  end
end
