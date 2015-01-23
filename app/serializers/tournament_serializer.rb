class TournamentSerializer < ActiveModel::Serializer
  attributes :id, :name, :ranking_type, :public, :created_at
  has_many :players

  def id
    object.to_param
  end

  def players
    object.players.active.includes(:user)
  end
end
