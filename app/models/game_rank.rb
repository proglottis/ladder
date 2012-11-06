class GameRank < ActiveRecord::Base
  belongs_to :rank
  has_one :user, :through => :rank
  belongs_to :game

  validates_numericality_of :position, :greater_than => 0, :only_integer => true

  def self.not_confirmed
    where(:confirmed_at => nil)
  end

  def self.with_participant(user)
    joins(:rank).where(:ranks => {:user_id => user})
  end

  def confirm
    update_attributes(:confirmed_at => Time.zone.now) unless confirmed?
  end

  def confirmed?
    confirmed_at != nil
  end
end
