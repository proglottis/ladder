class Match < ActiveRecord::Base
  belongs_to :championship
  belongs_to :game
  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player'
  belongs_to :winners_match, class_name: 'Match'
  belongs_to :losers_match, class_name: 'Match'

  has_many :previous_matches, class_name: 'Match', foreign_key: 'winners_match_id'

  enum bracket: [:winners, :losers]

  validates_presence_of :championship
  validates_presence_of :bracket

  def self.incomplete
    where(:game_id => nil)
  end

  def self.matches_game(game)
    winning_rank, losing_rank = game.game_ranks.minmax_by(&:position)
    joins(:championship).merge(Championship.where(:tournament_id => game.tournament_id)).
      where("(matches.player1_id = :winner AND matches.player2_id = :loser) OR " +
          "(matches.player1_id = :loser AND matches.player2_id = :winner)",
          winner: winning_rank.player, loser: losing_rank.player)
  end

  def self.unallocated
    where("matches.player1_id IS NULL OR matches.player2_id IS NULL")
  end

  def self.with_player(player)
    where("matches.player1_id = :player_id OR matches.player2_id = :player_id", player_id: player)
  end

  def self.find_root
    find_by winners_match_id: nil
  end

  def create_bracket!(players)
    if players.length == 3
      p1, p2, p3 = players
      match = championship.matches.winners.build(winners_match: self, losers_match: losers_match)
      if winners?
        add_player(p3)
        save!
        match.add_player(p1)
        match.add_player(p2)
      end
      match.save!
    elsif players.length <= 2
      old_losers_match = losers_match
      self.losers_match = old_losers_match.winners_match
      players.each do |player|
        add_player(player)
      end
      save!
      old_losers_match.destroy
    else
      half = (players.length / 2.0).floor
      losers1 = championship.matches.losers.create!(winners_match: losers_match)
      losers2 = championship.matches.losers.create!(winners_match: losers1)
      losers3 = championship.matches.losers.create!(winners_match: losers1)
      match1 = championship.matches.winners.create!(winners_match: self, losers_match: losers2)
      match1.create_bracket!(players.pop(half))
      match2 = championship.matches.winners.create!(winners_match: self, losers_match: losers3)
      match2.create_bracket!(players)
    end
  end

  def allocated?
    player1 && player2
  end

  def add_player(player)
    return if player1 == player || player2 == player
    if player1.nil?
      self.player1 = player
    elsif player2.nil?
      self.player2 = player
    end
  end
end
