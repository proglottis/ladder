module ApplicationHelper

  def gravatar_image_url(email, size = 16)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://secure.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end

  def gravatar_image_tag(email, size = 16, opts = {})
    image_tag gravatar_image_url(email, size), opts.merge!(:size => "#{size}x#{size}")
  end

  def cancel_link(path)
    link_to t('helpers.cancel_link'), path, :class => 'btn'
  end

  def markdown(text)
    options = {
      :fenced_code_blocks => true
    }
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, options).render(text).html_safe
  end
end
