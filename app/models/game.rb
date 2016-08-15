class Game < ApplicationRecord
  belongs_to :tournament
  belongs_to :owner, :class_name => 'User'
  has_many :events, -> { order("id ASC") }, :class_name => 'GameEvent', :dependent => :destroy
  has_many :game_ranks, -> { order('position') }, :dependent => :destroy
  has_many :comments, -> { order('created_at DESC') }, :as => :commentable, :dependent => :destroy
  has_one :match, :dependent => :nullify

  has_many :users, :through => :game_ranks

  validate :not_duplicate
  validate :not_already_challenger, :if => :was_challenged?, :on => :create
  validate :not_already_challenged, :if => :was_challenged?, :on => :create
  validate :not_self, :if => :was_challenged?, :on => :create

  STATES = %w[incomplete challenged unconfirmed confirmed]
  delegate :incomplete?, :challenged?, :unconfirmed?, :confirmed?, :to => :current_state

  accepts_nested_attributes_for :game_ranks

  attr_accessor :response, :comment, :url

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

  def self.challenged_or_unconfirmed
    joins(:events).merge GameEvent.latest_state(["challenged", "unconfirmed"])
  end

  def self.challenger(user)
    challenged.participant(user).where(:owner_id => user)
  end

  def self.defender(user)
    challenged.participant(user).where.not(:owner_id => user)
  end

  def current_state
    (events.last.try(:state) || STATES.first).inquiry
  end

  def was_challenged?
    events.any? { |event| event.state == "challenged" }
  end

  def challenge_processed_at
    (created_at + 1.week).tomorrow.midnight
  end

  def challenger
    game_ranks.detect{|game_rank| game_rank.player.user_id == owner_id }.try(:player).try(:user)
  end

  def defender
    game_ranks.detect{|game_rank| game_rank.player.user_id != owner_id }.try(:player).try(:user)
  end

  def defender_response!
    raise "Cannot respond if game not challenge" unless challenged?
    return unless ['won', 'lost'].include?(response)
    tournament.with_lock do
      lock!
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
    tournament.with_lock do
      lock!

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

        reposition_winner(game_ranks)

        events.create! state: "confirmed"
        true
      else
        false
      end
    end
  end

  ##
  # This method is comvoluted becuase we have to factor in multiple players...
  #
  # Expects locking to be handled by caller
  def reposition_winner(game_ranks)
    return unless tournament.instantly_ranked?

    # if any players in this game have no position, add them to the bottom of the ladder
    end_position = tournament.players.maximum(:position) || 0
    game_ranks.map(&:player).each do |player|
      next if player.position || !player.active?
      end_position += 1
      player.update_attributes!(:position => end_position)
    end

    ranks = game_ranks.sort_by(&:position)
    players = game_ranks.map(&:player).sort_by(&:position)

    winning_player = ranks.first.player
    return unless winning_player.active?

    winning_player_position = winning_player.position
    top_position_in_players = players.first.position
    return if winning_player_position == top_position_in_players # Winner is already at the top

    winning_player.update_attributes!(:position => :nil)

    players_who_get_shafted = tournament.players.where(:position => (top_position_in_players..winning_player_position))
    players_who_get_shafted.each do |player|
      player.update_attributes!(:position => player.position + 1)
    end

    winning_player.update_attributes!(:position => top_position_in_players)
  end

  def expire_challenge!
    raise "Cannot expire if game not challenge" unless challenged?
    tournament.with_lock do
      lock!
      game_ranks.each do |game_rank|
        if game_rank.user == owner
          game_rank.position = 1
        else
          game_rank.position = 2
        end
        game_rank.confirmed_at = Time.zone.now
        game_rank.save!
      end
      reposition_winner(game_ranks)
      events.build state: "confirmed"
      save!
    end
  end

  def versus
    game_ranks.map {|game_rank| game_rank.user.name}.to_sentence(:two_words_connector => I18n.t('support.array.versus.two_words_connector'))
  end

  private

  def not_already_challenged
    if tournament.games.defender(defender).any?
      errors[:base] << "Defender already challenged"
    end
  end

  def not_already_challenger
    if tournament.games.challenger(challenger).any?
      errors[:base] << "Challenger already challenging"
    end
  end

  def not_self
    if challenger == defender || defender.nil?
      errors[:base] << "Can't challenge yourself"
    end
  end

  def not_duplicate
    game_ranks = self.game_ranks.to_a
    if game_ranks.map(&:player_id).sort != game_ranks.map(&:player_id).uniq.sort
      errors[:base] << "Can't have duplicate players"
    end
  end
end
