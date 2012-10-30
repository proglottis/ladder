module ApplicationHelper

  def gravitar_image_tag(email, size = 16)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    image_tag "http://www.gravatar.com/avatar/#{hash}?size=#{size}", :size => "#{size}x#{size}"
  end

end
