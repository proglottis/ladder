class Challenge < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :challenger, :class_name => 'User'
  belongs_to :defender, :class_name => 'User'
  belongs_to :game

  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at DESC'

  before_validation :generate_expires_at

  validate :not_already_challenged
  validate :not_self

  attr_accessor :response, :comment

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
    return unless ['won', 'lost'].include?(response)
    with_lock do
      game = build_response_game(response == 'won')
      game.save!
      update_attribute(:game, game)
      Notifications.game_confirmation(challenger, game).deliver
    end
  end

  def versus
    [challenger.name, defender.name].to_sentence(:two_words_connector => I18n.t('support.array.versus.two_words_connector'))
  end

  def build_default_game
    time = Time.zone.now
    game = Game.new(:tournament => tournament, :owner => challenger, :confirmed_at => time)
    game.game_ranks.build(:user => challenger, :position => 1, :confirmed_at => time)
    game.game_ranks.build(:user => defender, :position => 2, :confirmed_at => time)
    game
  end

  def participant?(user)
    user.id == challenger_id || user.id == defender_id
  end

  private

  def build_response_game(winner)
    game = Game.new(:tournament => tournament, :owner => challenger)
    if winner
      game.game_ranks.build(:user => defender, :position => 1, :confirmed_at => Time.zone.now)
      game.game_ranks.build(:user => challenger, :position => 2)
    else
      game.game_ranks.build(:user => defender, :position => 2, :confirmed_at => Time.zone.now)
      game.game_ranks.build(:user => challenger, :position => 1)
    end
    game
  end

  def generate_expires_at
    self.expires_at = 7.days.from_now
  end

  def not_already_challenged
    if self.class.active.defending(defender).where(:tournament_id => tournament_id).length > 0
      errors.add(:defender, 'already challenged')
    end
  end

  def not_self
    if defender_id == challenger_id
      errors.add(:defender, 'is challenger')
    end
  end
end
