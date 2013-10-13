class Tournament < ActiveRecord::Base
  OWNER_LIMIT = 5

  extend FriendlyId
  friendly_id :slug_canditates, use: :slugged

  belongs_to :owner, :class_name => 'User'

  has_many :players, :dependent => :destroy
  has_many :invites, :dependent => :destroy
  has_many :invite_requests, :dependent => :destroy
  has_many :games, :dependent => :destroy
  has_many :challenges, :dependent => :destroy
  has_many :rating_periods, :dependent => :destroy
  has_one :page, :as => :parent, :dependent => :destroy

  has_many :users, :through => :players
  has_many :game_ranks, :through => :games
  has_many :ratings, :through => :rating_periods

  accepts_nested_attributes_for :page, :reject_if => :all_blank

  validates_presence_of :name, :owner_id
  validate :maximum_allowed

  def self.participant(user)
    tournaments = arel_table
    players = Player.arel_table
    invites = Invite.arel_table
    joins(tournaments.join(invites, Arel::Nodes::OuterJoin).on(invites[:tournament_id].eq(tournaments[:id])).
          join(players, Arel::Nodes::OuterJoin).on(players[:tournament_id].eq(tournaments[:id])).
          join_sql).
      where(tournaments[:owner_id].eq(user.id).
            or(players[:user_id].eq(user.id)).
            or(invites[:user_id].eq(user.id)).
            or(invites[:email].eq(user.email))).
      uniq.readonly(false)
  end

  def self.participant_or_public(user)
    tournaments = arel_table
    players = Player.arel_table
    invites = Invite.arel_table
    joins(tournaments.join(invites, Arel::Nodes::OuterJoin).on(invites[:tournament_id].eq(tournaments[:id])).
          join(players, Arel::Nodes::OuterJoin).on(players[:tournament_id].eq(tournaments[:id])).
          join_sql).
      where(tournaments[:owner_id].eq(user.id).
            or(tournaments[:public].eq(true)).
            or(players[:user_id].eq(user.id)).
            or(invites[:user_id].eq(user.id)).
            or(invites[:email].eq(user.email))).
      uniq.readonly(false)
  end

  def self.with_rated_user(*users)
    tournaments = arel_table
    n = 0
    user_joins = users.reduce(tournaments) do |user_joins, user|
      n += 1
      players = Player.arel_table.alias("with_rated_user_players_#{n}")
      user_joins.join(players).on(players[:tournament_id].eq(tournaments[:id]).
                                  and(players[:user_id].eq(user.id)))
    end
    joins(user_joins.join_sql).uniq
  end

  def self.anonymize
    find_each do |tournament|
      tournament.anonymize
    end
  end

  def anonymize
    update_attributes :name => "Tournament #{id}"
  end

  def current_rating_period
    rating_periods.order('rating_periods.period_at DESC').first
  end

  def self.limit_left
    OWNER_LIMIT - count
  end

  def slug_canditates
    [
      :name,
      [:name, :id],
    ]
  end

  def can_join?(user)
    invites.find_by(user_id: user) && !players.find_by(user_id: user)
  end

  def can_request_invite?(user)
    public? && user.id != owner_id && !players.find_by(user_id: user)
  end

  private

  def maximum_allowed
    if self.class.where(:owner_id => owner).reload.limit_left < 1
      errors.add(:base, 'Exceeded limit')
    end
  end
end
