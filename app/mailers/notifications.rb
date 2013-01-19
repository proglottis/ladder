class Notifications < ActionMailer::Base
  default from: "ladder@nothing.co.nz"

  def game_confirmation(user, game)
    @user = user
    @game = game
    @tournament = @game.tournament
    mail(:to => @user.email, :subject => "Confirm game")
  end
end
