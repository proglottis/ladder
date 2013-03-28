class RatingPeriod < ActiveRecord::Base
  belongs_to :tournament

  has_many :ratings, :dependent => :destroy

  validates_presence_of :tournament_id, :period_at
end
