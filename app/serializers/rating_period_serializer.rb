class RatingPeriodSerializer < ActiveModel::Serializer
  embed :ids, :include => true
  attributes :id, :tournament_id, :period_at, :created_at, :updated_at
  has_many :ratings
end
