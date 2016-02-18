class NotificationsPreview < ActionMailer::Preview
  def tournament_invitation
    Notifications.tournament_invitation(Invite.last)
  end

  def game_confirmation
    Notifications.game_confirmation(User.last, Game.last)
  end

  def game_confirmed
    Notifications.game_confirmed(User.last, Game.last)
  end

  def challenged
    Notifications.challenged(Game.last)
  end

  def commented
    Notifications.commented(User.last, Comment.last)
  end

  def invite_requested
    Notifications.invite_requested(InviteRequest.last)
  end

  def unconfirmed_games
    Notifications.unconfirmed_games(User.last, [GameRank.first, GameRank.last])
  end
end
