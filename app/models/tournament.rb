class Tournament < ActiveRecord::Base
  OWNER_LIMIT = 5

  belongs_to :owner, :class_name => 'User'
  has_many :glicko2_ratings
  has_many :users, :through => :glicko2_ratings
  has_many :invites
  has_many :games
  has_many :game_ranks, :through => :games

  validates_presence_of :name, :owner_id
  validate :maximum_allowed

  def self.participant(user)
    tournaments = arel_table
    ratings = Glicko2Rating.arel_table
    invites = Invite.arel_table
    includes(:glicko2_ratings, :invites).where(tournaments[:owner_id].eq(user.id).
                                         or(ratings[:user_id].eq(user.id)).
                                         or(invites[:user_id].eq(user.id)).
                                         or(invites[:email].eq(user.email)))
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
