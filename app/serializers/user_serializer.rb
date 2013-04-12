class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :large_image_url

  def large_image_url
    object.image_url 64
  end
end
