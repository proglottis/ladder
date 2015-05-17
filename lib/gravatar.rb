class Gravatar
  def self.image_url(email, size=16)
    return nil unless email
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end
end
