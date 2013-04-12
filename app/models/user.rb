class User < ActiveRecord::Base
  belongs_to :preferred_service, :class_name => 'Service'
  has_many :services
  has_many :tournaments, :inverse_of => :owner, :foreign_key => :owner_id
  has_many :invites, :inverse_of => :owner, :foreign_key => :owner_id

  def image_url(size=16)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end
end
