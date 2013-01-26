module ApplicationHelper

  def gravatar_image_tag(email, size = 16, opts = {})
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    image_tag "https://secure.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon", opts.merge!(:size => "#{size}x#{size}")
  end

end
