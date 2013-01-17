class GameRank < ActiveRecord::Base
  belongs_to :game
  belongs_to :user

  validates_numericality_of :position, :greater_than => 0, :only_integer => true

  def self.not_confirmed
    where(:confirmed_at => nil)
  end

  def self.with_participant(user)
    where(:user_id => user)
  end

  def confirm
    with_lock do
      update_attributes!(:confirmed_at => Time.zone.now) unless confirmed?
    end
  end

  def confirmed?
    confirmed_at != nil
  end
end
