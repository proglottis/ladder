class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament

  has_many :ratings, :dependent => :destroy
  has_many :game_ranks, :dependent => :destroy

  STREAK_THRESHOLD = 3

  def streak?
    winning_streak? || losing_streak?
  end

  def winning_streak?
    winning_streak_count >= STREAK_THRESHOLD && losing_streak_count < 1
  end

  def losing_streak?
    losing_streak_count >= STREAK_THRESHOLD && winning_streak_count < 1
  end
end
