require 'gravatar'

class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url

  def id
    object.to_param
  end

  def image_url
    Gravatar.image_url(object.email, 40)
  end
end
