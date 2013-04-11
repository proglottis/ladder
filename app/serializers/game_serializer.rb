class GameSerializer < ActiveModel::Serializer
  attributes :id, :tournament_id, :versus, :confirmed_at, :created_at, :updated_at, :image_url

  def image_url
    hash = Digest::MD5.hexdigest(object.game_ranks.first.user.email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{hash}?s=64&d=identicon"
  end
end
