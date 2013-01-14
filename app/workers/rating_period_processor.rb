class RatingPeriodProcessor
  def initialize(started_on, ended_on)
    @started_on = started_on
    @ended_on = ended_on
  end

  def self.perform
    ended_on = Time.zone.now.beginning_of_week
    processor = new(ended_on - 1.week, ended_on)
    processor.process
  end

  def process
    Tournament.find_each do |tournament|
      tournament.with_lock do
        period = Glicko2::RatingPeriod.from_objs(tournament.glicko2_ratings)
        tournament.games.where(:updated_at => @started_on..@ended_on).each do |game|
          ratings = Glicko2Rating.for_game(game)
          period.game ratings, ratings.map(&:position)
        end
        new_period = period.generate_next
        new_period.players.each do |player|
          player.update_obj
          player.obj.save!
        end
      end
    end
  end
end
