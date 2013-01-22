class Game < ActiveRecord::Base
  belongs_to :tournament
  has_many :game_ranks, :dependent => :destroy, :order => 'position'

  accepts_nested_attributes_for :game_ranks

  def self.with_participant(user)
    joins(:game_ranks).where(:game_ranks => {:user_id => user.id})
  end

  def confirm_user(user)
    with_lock do
      total = 0
      confirmed = 0
      game_ranks.each do |game_rank|
        game_rank.confirm if game_rank.user == user
        confirmed += 1 if game_rank.confirmed?
        total += 1
      end
      if total == confirmed
        update_attributes!(:confirmed_at => Time.zone.now) if confirmed_at.blank?
        true
      else
        false
      end
    end
  end

  def confirmed?
    confirmed_at != nil
  end

  def name
    tournament.name
  end

  def versus
    game_ranks.map {|game_rank| game_rank.user.name}.join(' vs ')
  end
end
