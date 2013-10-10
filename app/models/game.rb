class Game < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :owner, :class_name => 'User'
  has_many :events, :class_name => 'GameEvent', :dependent => :destroy
  has_many :game_ranks, -> { order('position') }, :dependent => :destroy
  has_many :comments, -> { order('created_at DESC') }, :as => :commentable, :dependent => :destroy
  has_one :challenge

  has_many :users, :through => :game_ranks

  STATES = %w[incomplete challenged unconfirmed confirmed]
  delegate :incomplete?, :challenged?, :unconfirmed?, :confirmed?, :to => :current_state

  accepts_nested_attributes_for :game_ranks

  attr_accessor :response, :comment

  def self.participant(user)
    joins(:game_ranks).merge GameRank.with_participant(user)
  end

  def self.confirmed_between(start_at, end_at)
    joins(:events).merge GameEvent.where(:created_at => start_at..end_at).latest_state("confirmed")
  end

  def self.unconfirmed
    joins(:events).merge GameEvent.latest_state("unconfirmed")
  end

  def self.challenged
    joins(:events).merge GameEvent.latest_state("challenged")
  end

  def current_state
    (events.order("id ASC").last.try(:state) || STATES.first).inquiry
  end

  def was_challenged?
    events.any? { |event| event.state == "challenged" }
  end

  def challenge_processed_at
    (created_at + 1.week).tomorrow.midnight
  end

  def challenger
    users.detect{|user| user == owner}
  end

  def defender
    users.detect{|user| user != owner }
  end

  def defender_response!
    raise "Cannot respond if game not challenge" unless challenged?
    return unless ['won', 'lost'].include?(response)
    with_lock do
      if response == 'won'
        game_ranks.each do |game_rank|
          if game_rank.user == owner
            game_rank.position = 2
          else
            game_rank.position = 1
            game_rank.confirmed_at = Time.zone.now
          end
          game_rank.save!
        end
      else
        game_ranks.each do |game_rank|
          if game_rank.user == owner
            game_rank.position = 1
          else
            game_rank.position = 2
            game_rank.confirmed_at = Time.zone.now
          end
          game_rank.save!
        end
      end
      events.build(state: 'unconfirmed')
      save!
    end
  end

  def confirm_user(user)
    raise "Cannot confirm if game is incomplete" if incomplete? || challenged?
    with_lock do
      total = 0
      confirmed = 0
      game_ranks.each do |game_rank|
        game_rank.confirm if game_rank.user == user
        confirmed += 1 if game_rank.confirmed?
        total += 1
      end
      if total == confirmed
        return true if confirmed?
        winning_rank, losing_rank = game_ranks.minmax_by(&:position)
        game_ranks.each do |game_rank|
          if game_rank.position == winning_rank.position && winning_rank.position != losing_rank.position
            game_rank.player.update_attributes!(:winning_streak_count => game_rank.player.winning_streak_count + 1,
                                                :losing_streak_count => 0)
          elsif game_rank.position == losing_rank.position && winning_rank.position != losing_rank.position
            game_rank.player.update_attributes!(:winning_streak_count => 0,
                                                :losing_streak_count => game_rank.player.losing_streak_count + 1)
          else
            game_rank.player.update_attributes!(:winning_streak_count => 0,
                                                :losing_streak_count => 0)
          end
        end
        events.create! state: "confirmed"
        true
      else
        false
      end
    end
  end

  def expire_challenge!
    raise "Cannot expire if game not challenge" unless challenged?
    with_lock do
      game_ranks.each do |game_rank|
        if game_rank.user == owner
          game_rank.position = 2
        else
          game_rank.position = 1
        end
        game_rank.confirmed_at = Time.zone.now
        game_rank.save!
      end
      events.build state: "confirmed"
      save!
    end
  end

  def name
    tournament.name
  end

  def versus
    game_ranks.map {|game_rank| game_rank.user.name}.to_sentence(:two_words_connector => I18n.t('support.array.versus.two_words_connector'))
  end
end
