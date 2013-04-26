class GameRankSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :user_id, :position, :confirmed_at, :created_at, :updated_at
end
