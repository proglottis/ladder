class Game < ActiveRecord::Base
  belongs_to :tournament
  has_many :game_ranks, :order => 'position'

  accepts_nested_attributes_for :game_ranks

  def self.with_participant(user)
    joins(:game_ranks).where(:game_ranks => {:user_id => user.id})
  end

  def confirmed?
    game_ranks.not_confirmed.count < 1
  end

  def name
    tournament.name
  end

  def versus
    game_ranks.map {|game_rank| game_rank.user.name}.join(' vs ')
  end
end
