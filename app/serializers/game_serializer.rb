class GameSerializer < ActiveModel::Serializer
  attributes :id, :created_at
  has_one :tournament, serializer: TournamentListSerializer
  has_one :owner
  has_many :game_ranks
  has_many :comments
end
