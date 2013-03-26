class GamesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @pending = GameRank.not_confirmed.with_participant(current_user)
    @unconfirmed = Game.with_participant(current_user).unconfirmed
  end

  def new
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
    @game = @tournament.games.build
    @game.game_ranks.build :user => @tournament.users.find(current_user), :position => 1
    @game.game_ranks.build :user => @tournament.users.find(params[:user_id]), :position => 2
  end

  def create
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
    @game = @tournament.games.build params.require(:game).permit(:game_ranks_attributes => [:user_id, :position])
    @game.owner = current_user
    if @game.save
      @game.game_ranks.with_participant(current_user).readonly(false).first!.confirm
      @game.game_ranks.each do |game_rank|
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
    @current_game_rank = @game_ranks.detect {|game_rank| game_rank.user_id == current_user.id }
  end

  def confirm
    @game = Game.with_participant(current_user).readonly(false).find(params[:id])
    if @game.confirm_user(current_user)
      @game.game_ranks.each do |game_rank|
        if game_rank.user != current_user && game_rank.user.game_confirmed_email?
          Notifications.game_confirmed(game_rank.user, @game).deliver
        end
      end
      redirect_to games_path
    else
      redirect_to game_path(@game)
    end
  end
end
