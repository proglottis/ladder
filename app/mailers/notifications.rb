class Notifications < ActionMailer::Base
  default from: "ladders@ladders.pw"

  def tournament_invitation(invite)
    @invite = invite
    @tournament = invite.tournament
    mail(to: invite.email, subject: t('notifications.tournament_invitation.subject'))
  end

  def game_confirmation(user, game)
    @user = user
    @game = game
    @tournament = @game.tournament
    mail(to: @user.email, subject: t('notifications.game_confirmation.subject', game: @game.versus))
  end

  def game_confirmed(user, game)
    @user = user
    @game = game
    @tournament = @game.tournament
    mail(to: @user.email, subject: t('notifications.game_confirmed.subject', game: @game.versus))
  end

  def challenged(challenge)
    @challenge = challenge
    @defender = challenge.defender
    @challenger = challenge.challenger
    @tournament = challenge.tournament
    mail(to: @defender.email, subject: t('notifications.challenged.subject', tournament: @tournament.name))
  end

  def commented(user, comment)
    @user = user
    @comment = comment
    @commentable = comment.commentable
    mail(to: @user.email, subject: t('notifications.commented.subject', commentable: @commentable.versus))
  end

  def invite_requested(invite_request)
    @invite_request = invite_request
    @tournament = invite_request.tournament
    @user = @tournament.owner
    mail(to: @user.email, subject: t('notifications.invite_requested.subject', tournament: @tournament.name))
  end

  def invite_request_accepted(invite_request)
    @invite_request = invite_request
    @tournament = invite_request.tournament
    @user = @invite_request.user
    mail(to: @user.email, subject: t('notifications.invite_request_accepted.subject', tournament: @tournament.name))
  end

  def championship_match(user, match)
    @user = user
    @match = match
    @other = match.player1.user == @user ? match.player2 : match.player1
    @championship = match.championship
    @tournament = match.championship.tournament
    mail(to: @user.email, subject: t('notifications.championship_match.subject', tournament: @tournament.name))
  end

  def unconfirmed_games(user, game_ranks)
    @user = user
    @game_ranks = game_ranks
    mail(to: @user.email, subject: t('notifications.unconfirmed_games.subject'))
  end
end
