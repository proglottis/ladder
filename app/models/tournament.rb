class Tournament < ActiveRecord::Base
  OWNER_LIMIT = 5

  belongs_to :owner, :class_name => 'User'

  has_many :glicko2_ratings, :dependent => :destroy
  has_many :invites, :dependent => :destroy
  has_many :games, :dependent => :destroy
  has_many :challenges, :dependent => :destroy
  has_many :rating_periods, :dependent => :destroy
  has_one :page, :as => :parent, :dependent => :destroy

  has_many :ratings, :through => :rating_periods
  has_many :users, :through => :ratings
  has_many :game_ranks, :through => :games

  accepts_nested_attributes_for :page, :reject_if => :all_blank

  validates_presence_of :name, :owner_id
  validate :maximum_allowed

  def self.participant(user)
    tournaments = arel_table
    ratings = Rating.arel_table
    invites = Invite.arel_table
    includes(:ratings, :invites).where(tournaments[:owner_id].eq(user.id).
                                         or(ratings[:user_id].eq(user.id)).
                                         or(invites[:user_id].eq(user.id)).
                                         or(invites[:email].eq(user.email)))
  end

  def self.with_rated_user(*users)
    rating_periods = RatingPeriod.arel_table
    tournaments = arel_table.join(rating_periods).
      on(arel_table[:id].eq(rating_periods[:tournament_id]))
    n = 0
    user_joins = users.reduce(tournaments) do |user_joins, user|
      n += 1
      ratings = Rating.arel_table.alias("ratings_with_participant_#{n}")
      user_joins.join(ratings).on(rating_periods[:id].eq(ratings[:rating_period_id]).
                                  and(ratings[:user_id].eq(user.id)))
    end
    joins(user_joins.join_sql)
  end

  def current_rating_period
    rating_periods.order('rating_periods.period_at DESC').first
  end

  def self.limit_left
    OWNER_LIMIT - count
  end

  def has_user?(user)
    users.where(:users => {:id => user}).present?
  end

  private

  def maximum_allowed
    if owner.tournaments.reload.limit_left < 1
      errors.add(:base, 'Exceeded limit')
    end
  end
end
