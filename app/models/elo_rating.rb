class EloRating < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament

  def self.with_defaults
    where(:rating => 1000, :games_played => 0, :pro => false)
  end

end