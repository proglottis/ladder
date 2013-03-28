class BackpopulateRatingPeriods < ActiveRecord::Migration
  def up
    Tournament.find_each do |tournament|
      first_game = tournament.games.where('confirmed_at is not null').order('confirmed_at').first
      if first_game.present?
        start_date = first_game.confirmed_at.beginning_of_week
      else
        start_date = tournament.created_at.beginning_of_week
      end
      while start_date < Time.zone.now
        period = tournament.rating_periods.create!(:period_at => start_date)
        tournament.glicko2_ratings.where(:created_at => start_date..(start_date + 1.week)).find_each do |rating|
          period.ratings.with_defaults.create!(:user_id => rating.user_id)
        end
        period.process!
        start_date += 1.week
      end
    end
  end

  def down
    RatingPeriod.destroy_all
  end
end
