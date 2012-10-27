class GameRank < ActiveRecord::Base
  belongs_to :rank
  has_one :user, :through => :rank
  belongs_to :game

  acts_as_list :scope => :game

  def self.not_confirmed
    where(:confirmed_at => nil)
  end

  def self.with_participant(user)
    joins(:rank).where(:ranks => {:user_id => user})
  end

  def confirm
    update_attributes(:confirmed_at => Time.now) unless confirmed?
  end

  def confirmed?
    confirmed_at != nil
  end
end
