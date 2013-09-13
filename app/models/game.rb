class Game < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :owner, :class_name => 'User'
  has_many :events, :class_name => 'GameEvent', :dependent => :destroy
  has_many :game_ranks, -> { order('position') }, :dependent => :destroy
  has_many :comments, -> { order('created_at DESC') }, :as => :commentable, :dependent => :destroy
  has_one :challenge

  STATES = %w[incomplete unconfirmed confirmed]
  delegate :incomplete?, :unconfirmed?, :confirmed?, :to => :current_state

  accepts_nested_attributes_for :game_ranks

  attr_accessor :comment

  def self.participant(user)
    joins(:game_ranks => :player).where(:players => {:user_id => user})
  end

  def self.unconfirmed
    joins(:events).merge GameEvent.latest_state("unconfirmed")
  end

  def current_state
    (events.last.try(:state) || STATES.first).inquiry
  end

  def confirm_user(user)
    raise "Cannot confirm if game is incomplete" if incomplete?
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

  def name
    tournament.name
  end

  def versus
    game_ranks.map {|game_rank| game_rank.user.name}.to_sentence(:two_words_connector => I18n.t('support.array.versus.two_words_connector'))
  end
end
