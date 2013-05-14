class Notifications < ActionMailer::Base
  default from: "ladders@ladders.pw"

  def tournament_invitation(invite)
    @invite = invite
    @tournament = invite.tournament
    mail(:to => invite.email, :subject => t('notifications.tournament_invitation.subject'))
  end

  def game_confirmation(user, game)
    @user = user
    @game = game
    @tournament = @game.tournament
    mail(:to => @user.email, :subject => t('notifications.game_confirmation.subject'))
  end

  def game_confirmed(user, game)
    @user = user
    @game = game
    @tournament = @game.tournament
    mail(:to => @user.email, :subject => t('notifications.game_confirmed.subject'))
  end

  def challenged(challenge)
    @challenge = challenge
    @defender = challenge.defender
    @challenger = challenge.challenger
    @tournament = challenge.tournament
    mail(:to => @defender.email, :subject => t('notifications.challenged.subject'))
  end
end
