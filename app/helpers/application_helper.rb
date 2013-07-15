module ApplicationHelper
  class MarkdownHTML < Redcarpet::Render::HTML
    def header(text, level)
      slug = text.parameterize
      "<h#{level} id=\"#{slug}\">#{text}</h#{level}>"
    end
  end

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

  def delete_link(path)
    link_to t('helpers.submit.delete'), path, method: :delete, data: {confirm: 'Are you sure?'}, :class => 'btn btn-danger pull-right'
  end

  def markdown(text)
    extensions = { :fenced_code_blocks => true }
    render_opts = { :filter_html => true, :no_styles => true, :safe_links_only => true }
    Redcarpet::Markdown.new(MarkdownHTML.new(render_opts), extensions).render(text).html_safe
  end

  def render_single(model)
    render [model].compact
  end
end
