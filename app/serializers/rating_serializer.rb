class RatingSerializer < ActiveModel::Serializer
  attributes :id, :tournament_id, :user_id, :low_rank

  def tournament_id
    object.rating_period.tournament_id
  end
end
