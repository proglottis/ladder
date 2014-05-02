class Championship < ActiveRecord::Base
  belongs_to :tournament

  has_many :championship_players, dependent: :destroy
  has_many :matches, dependent: :destroy

  has_many :players, through: :championship_players

  validates_presence_of :tournament
  validate :championship_not_ended, on: :create

  def self.incomplete
    joins(:matches).merge(Match.incomplete)
  end

  def self.started
    where(ended_at: nil).where.not(started_at: nil)
  end

  def self.active
    order('championships.ended_at ASC').last
  end

  def self.log_game!(game)
    allocated = []
    started.where(tournament_id: game.tournament_id).uniq.find_each do |championship|
      allocated += championship.log_game!(game)
    end
    allocated
  end

  def started?
    started_at.present?
  end

  def ended?
    ended_at.present?
  end

  def start!
    with_lock do
      matches.destroy_all
      players_array = players.to_a
      if players_array.length <= 2
        match = matches.winners.build
        players.each do |player|
          match.add_player(player)
        end
        match.save!
      else
        match = matches.winners.create!
        losers_match = matches.losers.create!(winners_match: match)
        winners_match = matches.winners.create!(winners_match: match, losers_match: losers_match)
        winners_match.create_bracket!(players_array)
      end
      update_attributes!(started_at: Time.zone.now)
    end
  end

  def log_game!(game)
    with_lock do
      allocated = []
      winning_rank, losing_rank = game.game_ranks.minmax_by(&:position)
      matches.incomplete.matches_game(game).find_each do |match|
        # find the winners new match
        if new_match = match.winners_match
          new_match.add_player(winning_rank.player)
          new_match.save!
          allocated << new_match if new_match.allocated?
        end
        if match.winners?
          # find the losers new match
          if new_match = match.losers_match
            new_match.add_player(losing_rank.player)
            new_match.save!
            allocated << new_match if new_match.allocated?
          elsif match.previous_matches.count > 1
            # Special case where the loser in the final has not lost before
            previous_winning_rank = match.previous_matches.winners.first.game.game_ranks.min_by(&:position)
            if previous_winning_rank.player == losing_rank.player
              new_match = matches.winners.build
              new_match.add_player(winning_rank.player)
              new_match.add_player(losing_rank.player)
              new_match.save!
              allocated << new_match if new_match.allocated?
              match.winners_match = new_match
            end
          end
        end
        match.update_attributes!(game: game)
      end
      update_if_ended!
      allocated
    end
  end

  def update_if_ended!
    update_attributes!(ended_at: Time.zone.now) if matches.incomplete.none?
  end

  def champions
    root = matches.find_by(winners_match_id: nil)
    results = root.game.game_ranks.minmax_by(&:position).map(&:player)
    if previous = root.previous_matches.losers.first
      results << previous.game.game_ranks.max_by(&:position).player
    elsif previous = root.previous_matches.winners.first.try(:losers).try(:first)
      results << previous.game.game_ranks.max_by(&:position).player
    end
    results
  end

  private

  def championship_not_ended
    if tournament.championships.where(ended_at: nil).any?
      errors.add(:base, 'another championship has not ended')
    end
  end
end
