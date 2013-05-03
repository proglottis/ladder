class TournamentSerializer < ActiveModel::Serializer
  embed :ids, :include => true
  attributes :id, :name, :created_at, :updated_at, :current_rating_period_id
  has_one :page

  def current_rating_period_id
    object.current_rating_period.id
  end
end
