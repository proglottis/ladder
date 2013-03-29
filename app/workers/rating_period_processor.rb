class RatingPeriodProcessor
  def initialize(at)
    @at = at
  end

  def self.perform
    at = Time.zone.now.beginning_of_week
    processor = new(at)
    processor.process
  end

  def process
    Tournament.find_each do |tournament|
      tournament.with_lock do
        rating_period = tournament.rating_periods.create!(:period_at => @at)
        rating_period.process!
      end
    end
  end
end
