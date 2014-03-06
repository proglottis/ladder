class ChallengesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_tournament_and_defender

  def new
    @game = @tournament.games.build
    @game.game_ranks.build :player => @tournament.players.active.find_by!(user_id: current_user)
    @game.game_ranks.build :player => @tournament.players.active.find_by!(user_id: @defender)
  end

  def create
    @game = @tournament.games.build params.require(:game).permit(:comment)
    @game.events.build state: 'challenged'
    @game.owner = current_user
    @game.game_ranks.build :player => @tournament.players.active.find_by!(user_id: current_user)
    @game.game_ranks.build :player => @tournament.players.active.find_by!(user_id: @defender)
    if @game.save
      CommentService.new(current_user).comment(@game, @game.comment)
      Notifications.challenged(@game).deliver
      redirect_to game_path(@game)
    else
      render :new
    end
  end

  private

  def find_tournament_and_defender
    @tournament = Tournament.with_rated_user(current_user).friendly.find(params[:tournament_id])
    @defender = @tournament.users.friendly.find(params[:user_id])
  end
end
