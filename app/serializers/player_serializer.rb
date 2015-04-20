class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :position, :tournament_id, :winning_streak_count, :losing_streak_count, :image_url
  has_one :user
end
