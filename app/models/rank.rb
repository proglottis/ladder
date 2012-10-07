class Rank < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament

  validates_presence_of :user_id, :tournament_id

  def rank
    mu - 3.0 * sigma
  end
end
