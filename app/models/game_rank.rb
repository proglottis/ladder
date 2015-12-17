class GameRank < ActiveRecord::Base
  belongs_to :game, touch: true
  belongs_to :player

  has_one :user, :through => :player

  validates_numericality_of :position, greater_than: 0, only_integer: true, if: -> game_rank { game_rank.game.try(:challenged?) }

  def self.not_confirmed
    where(:confirmed_at => nil)
  end

  def self.with_participant(user)
    joins(:player).where(:players => {:user_id => user})
  end

  def self.created_today
    t = Time.zone.now
    where(created_at: t.beginning_of_day..t.end_of_day)
  end

  def confirm
    with_lock do
      update_attributes!(:confirmed_at => Time.zone.now) unless confirmed?
    end
  end

  def confirmed?
    !unconfirmed?
  end

  def unconfirmed?
    confirmed_at.nil?
  end
end
