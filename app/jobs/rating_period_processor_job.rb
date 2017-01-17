class RatingPeriodProcessorJob < ApplicationJob
  queue_as :default

  def perform
    at = Time.zone.now.beginning_of_week

    Tournament.find_each do |tournament|
      tournament.with_lock do
        rating_period = tournament.rating_periods.create!(:period_at => at)
        rating_period.process!
        rating_period.update_player_positions!
      end
    end
  end
end
