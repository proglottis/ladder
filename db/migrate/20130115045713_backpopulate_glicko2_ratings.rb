class BackpopulateGlicko2Ratings < ActiveRecord::Migration
  def up
    Rank.find_each do |rank|
      Glicko2Rating.with_defaults.create! :user => rank.user, :tournament => rank.tournament
    end
    start_date = Game.order('confirmed_at').first.confirmed_at.beginning_of_week
    while start_date + 1.week < Time.zone.now
      processor = RatingPeriodProcessor.new(start_date, start_date + 1.week)
      processor.process
      start_date += 1.week
    end
  end

  def down
    Glicko2Rating.destroy_all
  end
end
