class GameConfirmer
  def initialize(user, game)
    @user = user
    @game = game
  end

  def confirm
    if @game.confirm_user(@user)
      @game.game_ranks.each do |game_rank|
        if game_rank.user != @user && game_rank.user.game_confirmed_email?
          Notifications.game_confirmed(game_rank.user, @game).deliver_now
        end
      end
      allocated = @game.tournament.championships.log_game!(@game)
      allocated.each do |match|
        Notifications.championship_match(match.player1.user, match).deliver_now
        Notifications.championship_match(match.player2.user, match).deliver_now
      end
    end
  end
end
