class CommentService
  def initialize(user)
    @user = user
  end

  def comment(commentable, content, subscribers=[])
    return unless content.present?
    comment = Comment.new(:commentable => commentable, :user => @user, :content => content)
    subscribers.each do |subscriber|
      Notifications.commented(subscriber, comment).deliver unless subscriber == @user
    end
  end
end
