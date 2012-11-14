class UpdateEloRatings < ActiveRecord::Migration
  def up
    Tournament.all.each do |tournament|
      tournament.users.each do |user|
        tournament.elo_ratings.with_defaults.create(:user => user)
      end

      tournament.games.order(:created_at).select(&:confirmed?).each do |game|
        game.process_elo
      end
    end
  end

  def down
    EloRating.destroy_all
  end
end

