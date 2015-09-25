include ActionView::Helpers::SanitizeHelper

class SimplifyComments < ActiveRecord::Migration
  def up
    Comment.find_each do |comment|
      comment.content.match(/!\[[^\]]*\]\(([^)]+)\)/) do |match|
        comment.url ||= match[1] if match[1].start_with?("http:", "https:")
      end
      comment.content = strip_tags(Kramdown::Document.new(comment.content).to_html).strip.presence
      if [comment.content.presence, comment.url.presence].compact.empty?
        comment.destroy
      else
        comment.save!
      end
    end
  end

  def down
    # No going back!
  end
end
