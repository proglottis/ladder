class TournamentSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :updated_at, :current_rating_period_id

  def current_rating_period_id
    object.current_rating_period.id
  end
end
