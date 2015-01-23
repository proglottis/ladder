class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :position, :tournament_id
  has_one :user
end
