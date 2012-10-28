class Tournament < ActiveRecord::Base
  OWNER_LIMIT = 5

  belongs_to :owner, :class_name => 'User'
  has_many :ranks
  has_many :users, :through => :ranks
  has_many :invites
  has_many :games

  validates_presence_of :name, :owner_id
  validate :maximum_allowed

  def self.participant(user)
    tournaments = arel_table
    ranks = Rank.arel_table
    invites = Invite.arel_table
    includes(:ranks, :invites).where(tournaments[:owner_id].eq(user.id).
                                     or(ranks[:user_id].eq(user.id)).
                                     or(invites[:user_id].eq(user.id)))
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
