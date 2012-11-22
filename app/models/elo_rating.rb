class EloRating < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament

  def self.with_defaults
    where(:rating => 1000, :games_played => 0, :pro => false)
  end

  def self.by_rating
    order('elo_ratings.rating DESC, elo_ratings.games_played DESC')
  end

end
