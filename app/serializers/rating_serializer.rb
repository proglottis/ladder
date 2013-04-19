class RatingSerializer < ActiveModel::Serializer
  attributes :id, :rating_period_id, :user_id, :low_rank
end
