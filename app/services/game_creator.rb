class GameCreator
  def initialize(user, tournament)
    @user = user
    @tournament = tournament
  end

  def create(params)
    game = @tournament.games.build params.require(:game).permit(:comment, :game_ranks_attributes => [:player_id, :position])
    game.events.build state: 'unconfirmed'
    game.owner = @user
    if game.save
      CommentService.new(@user).comment(game, game.comment)
      game.game_ranks.with_participant(@user).readonly(false).each(&:confirm)
      game.game_ranks.reload.each do |game_rank|
        Notifications.game_confirmation(game_rank.user, game).deliver_now unless game_rank.confirmed?
      end
      game
    end
  end
end
