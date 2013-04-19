class RatingSerializer < ActiveModel::Serializer
  attributes :id, :rating_period_id, :user_id, :low_rank

  def low_rank
    object.low_rank.round
  end
end
