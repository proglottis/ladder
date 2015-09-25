class GameCreator
  def initialize(user, tournament)
    @user = user
    @tournament = tournament
    if Rails.application.secrets.google_services_key
      @gcm = GCM.new(Rails.application.secrets.google_services_key)
    end
  end

  def create(params)
    game = @tournament.games.build params.require(:game).permit(:comment, :url, :game_ranks_attributes => [:player_id, :position])
    game.events.build state: 'unconfirmed'
    game.owner = @user
    if game.save
      CommentService.new(@user).comment(game, game.comment, game.url)
      game.game_ranks.with_participant(@user).readonly(false).each(&:confirm)
      gcm_ids = []
      game.game_ranks.reload.each do |game_rank|
        if !game_rank.confirmed?
          Notifications.game_confirmation(game_rank.user, game).deliver_now
          gcm_ids += game_rank.user.push_notification_keys.map(&:gcm)
        end
      end
      @gcm.send(gcm_ids, {
        collapse_key: "game_confirmation",
        data: { game_id: game.id }
      }) unless gcm_ids.empty?
      game
    end
  end
end
