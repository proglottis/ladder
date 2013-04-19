class RatingPeriodSerializer < ActiveModel::Serializer
  embed :ids, :include => true
  attributes :id, :tournament_id, :period_at, :created_at, :updated_at, :pending_count
  has_many :ratings

  def pending_count
    object.tournament.games.where('games.confirmed_at >= ?', object.period_at).count
  end
end
