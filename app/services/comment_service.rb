class CommentService
  def initialize(user)
    @user = user
  end

  def comment(commentable, content, subscribers=[])
    return unless content.present?
    comment = Comment.create!(:commentable => commentable, :user => @user, :content => content)
    subscribers.each do |subscriber|
      Notifications.commented(subscriber, comment).deliver_now if subscriber != @user && subscriber.commented_email?
    end
  end
end
