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

  def process
    with_lock do
      process_trueskill
      process_elo
    end
  end

  def process_trueskill
    with_lock do
      ratings = {}
      ranks = Rank.for_game(self).group_by {|r| r.id}
      ranks.values.map(&:first).each do |r|
        ratings[[TrueSkillRatingWithId.new(r.mu, r.sigma, 1.0, r.id)]] = r.position
      end
      graph = Saulabs::TrueSkill::FactorGraph.new(ratings)
      graph.update_skills
      ratings.keys.each do |ratings|
        ratings.each do |rating|
          ranks[rating.id][0].update_attributes!(:mu => rating.mean, :sigma => rating.deviation)
        end
      end
    end
  end

  def process_elo
    with_lock do
      winner_rating = winner.elo_ratings.where(:tournament_id => tournament).first
      loser_rating = loser.elo_ratings.where(:tournament_id => tournament).first

      winning_player = Elo::Player.new(winner_rating.attributes)
      losing_player = Elo::Player.new(loser_rating.attributes)

      winning_player.wins_from(losing_player)

      winner_rating.update_attributes(:rating => winning_player.rating, :games_played => winning_player.games_played, :pro => winning_player.pro?)
      loser_rating.update_attributes(:rating => losing_player.rating, :games_played => losing_player.games_played, :pro => losing_player.pro?)
    end
  end

  def name
    tournament.name
  end

  def winner
    game_ranks.order(:position).first.user
  end

  def loser
    game_ranks.order(:position).last.user
  end

  def versus
    game_ranks.map {|game_rank| game_rank.user.name}.join(' vs ')
  end
end
