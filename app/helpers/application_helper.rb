module ApplicationHelper

  def gravatar_image_tag(email, size = 16)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    image_tag "https://secure.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon", :size => "#{size}x#{size}"
  end

end
