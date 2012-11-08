module ApplicationHelper

  def gravatar_image_tag(email, size = 16)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    image_tag "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon", :size => "#{size}x#{size}"
  end

  def render_rank(rank)
    level = 'badge-important'
    if rank.sigma < 1.5
      level = 'badge-success'
    elsif rank.sigma < 4
      level = 'badge-warning'
    end
    content_tag :span, :class => "badge #{level}" do
      number_with_precision rank.rank
    end
  end

end
