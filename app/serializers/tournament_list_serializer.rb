class TournamentListSerializer < ActiveModel::Serializer
  attributes :id, :name, :ranking_type, :public, :created_at

  def id
    object.to_param
  end
end

