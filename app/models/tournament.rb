class Tournament < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :ranks
  has_many :users, :through => :ranks
  has_many :invites

  attr_accessible :name

  validates_presence_of :name, :owner_id

  def self.participant(user)
    tournaments = arel_table
    ranks = Rank.arel_table
    invites = Invite.arel_table
    includes(:ranks, :invites).where(tournaments[:owner_id].eq(user.id).
                                     or(ranks[:user_id].eq(user.id)).
                                     or(invites[:user_id].eq(user.id)))
  end

  def has_user?(user)
    users.where(:users => {:id => user}).present?
  end
end
