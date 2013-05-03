class PageSerializer < ActiveModel::Serializer
  attributes :id, :content, :updated_at, :created_at
end
