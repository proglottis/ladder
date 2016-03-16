class CommentService
  def initialize(user, notify = true)
    @user = user
    @notify = notify
  end

  def comment(commentable, content, url, subscribers=[])
    url = nil if url && !url.starts_with?('http:', 'https:')
    return if [content.presence, url.presence].compact.empty?
    comment = Comment.create!(:commentable => commentable, :user => @user, :content => content, :url => url)
    return unless @notify
    subscribers.each do |subscriber|
      Notifications.commented(subscriber, comment).deliver_now if subscriber != @user && subscriber.commented_email?
    end
  end
end
