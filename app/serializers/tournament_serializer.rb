class TournamentSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :updated_at, :rating_ids

  def rating_ids
    object.current_rating_period.ratings.pluck(:id)
  end
end
