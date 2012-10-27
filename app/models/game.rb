class Game < ActiveRecord::Base
  belongs_to :tournament
  has_many :game_ranks, :order => 'position'

  accepts_nested_attributes_for :game_ranks

  def self.with_participant(user)
    includes(:game_ranks => {:rank => :user}).where(:ranks => {:user_id => user.id})
  end

  def confirmed?
    game_ranks.not_confirmed.count < 1
  end

  def process
    with_lock do
      ratings = []
      positions = []
      list = game_ranks.includes(:rank).all
      list.each do |game_rank|
        ratings << [Saulabs::TrueSkill::Rating.new(game_rank.rank.mu, game_rank.rank.sigma, 1.0)]
        positions << game_rank.position
      end
      graph = Saulabs::TrueSkill::FactorGraph.new(ratings, positions)
      graph.update_skills
      ratings.each_with_index do |rating, index|
        list[index].rank.update_attributes(:mu => rating[0].mean, :sigma => rating[0].deviation)
      end
    end
  end

  def name
    tournament.name
  end

  def versus
    game_ranks.map {|game_rank| game_rank.rank.user.name}.join(' vs ')
  end
end
