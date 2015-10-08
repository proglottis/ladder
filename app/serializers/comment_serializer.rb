class CommentSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :content, :url
  has_one :user
end
