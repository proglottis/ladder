class GameRankSerializer < ActiveModel::Serializer
  attributes :id, :position, :confirmed_at
  has_one :player
end
