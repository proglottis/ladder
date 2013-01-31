class Notifications < ActionMailer::Base
  default from: "ladder@nothing.co.nz"

  def tournament_invitation(invite)
    @invite = invite
    @tournament = invite.tournament
    mail(:to => invite.email, :subject => "You have been invited")
  end

  def game_confirmation(user, game)
    @user = user
    @game = game
    @tournament = @game.tournament
    mail(:to => @user.email, :subject => "Confirm game")
  end

  def challenged(challenge)
    @challenge = challenge
    @defender = challenge.defender
    @challenger = challenge.challenger
    @tournament = challenge.tournament
    mail(:to => @defender.email, :subject => "You have been challenged")
  end
end
