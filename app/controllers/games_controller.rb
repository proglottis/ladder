class GamesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @pending = GameRank.not_confirmed.with_participant(current_user).includes(:user)
    @unconfirmed = Game.with_participant(current_user).unconfirmed.includes(:game_ranks => :user)
  end

  def new
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
    @game = @tournament.games.build
    @game.game_ranks.build :player => @tournament.players.find_by!(user_id: current_user), :position => 1
    @game.game_ranks.build :player => @tournament.players.find_by!(user_id: params[:user_id]), :position => 2
  end

  def create
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
    @game = @tournament.games.build params.require(:game).permit(:comment, :game_ranks_attributes => [:player_id, :position])
    @game.owner = current_user
    if @game.save
      CommentService.new(current_user).comment(@game, @game.comment)
      @game.game_ranks.with_participant(current_user).readonly(false).first!.confirm
      @game.game_ranks.reload.each do |game_rank|
        Notifications.game_confirmation(game_rank.user, @game).deliver unless game_rank.confirmed?
      end
      redirect_to game_path(@game)
    else
      render :new
    end
  end

  def show
    @game = Game.with_participant(current_user).find(params[:id])
    @tournament = @game.tournament
    @game_ranks = @game.game_ranks.includes(:user)
    @current_game_rank = @game_ranks.detect {|game_rank| game_rank.user.id == current_user.id }
    @challenge = @game.challenge
    @comments = @game.comments
  end

  def update
    @game = Game.with_participant(current_user).readonly(false).find(params[:id])
    @game.attributes = params.require(:game).permit(:comment)
    CommentService.new(current_user).comment(@game, @game.comment, @game.game_ranks.map(&:user))
    if params.has_key?(:confirm)
      if @game.confirm_user(current_user)
        @game.game_ranks.each do |game_rank|
          if game_rank.user != current_user && game_rank.user.game_confirmed_email?
            Notifications.game_confirmed(game_rank.user, @game).deliver
          end
        end
      end
    end
    redirect_to game_path(@game)
  end
end
