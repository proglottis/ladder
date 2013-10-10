class GamesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_game_and_tournament, :only => [:show, :update]

  def index
    @games = Game.participant(current_user).unconfirmed.includes(:tournament, :game_ranks => :user)
    @unconfirmed, @pending = @games.partition { |game| game.game_ranks.detect{|rank| rank.user == current_user}.confirmed? }
  end

  def new
    @tournament = Tournament.with_rated_user(current_user).friendly.find(params[:tournament_id])
    @other_user = User.friendly.find(params[:user_id])
    @game = @tournament.games.build
    @game.game_ranks.build :player => @tournament.players.find_by!(user_id: current_user), :position => 1
    @game.game_ranks.build :player => @tournament.players.find_by!(user_id: @other_user), :position => 2
  end

  def create
    @tournament = Tournament.with_rated_user(current_user).friendly.find(params[:tournament_id])
    @game = @tournament.games.build params.require(:game).permit(:comment, :game_ranks_attributes => [:player_id, :position])
    @game.events.build state: 'unconfirmed'
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
    @game_ranks = @game.game_ranks.includes(:user)
    @current_game_rank = @game_ranks.detect {|game_rank| game_rank.user.id == current_user.id }
    @comments = @game.comments
  end

  def update
    @game.attributes = params.require(:game).permit(:response, :comment)
    CommentService.new(current_user).comment(@game, @game.comment, @game.game_ranks.map(&:user))
    if params.has_key?(:confirm)
      if @game.confirm_user(current_user)
        @game.game_ranks.each do |game_rank|
          if game_rank.user != current_user && game_rank.user.game_confirmed_email?
            Notifications.game_confirmed(game_rank.user, @game).deliver
          end
        end
      end
    elsif params.has_key?(:respond)
      @game.defender_response!
      if @game.confirmed?
        @game.game_ranks.reload.each do |game_rank|
          Notifications.game_confirmation(game_rank.user, @game).deliver unless game_rank.confirmed?
        end
      end
    end
    redirect_to game_path(@game)
  end

  private

  def find_game_and_tournament
    @game = Game.find(params[:id])
    @tournament = Tournament.with_rated_user(current_user).friendly.find(@game.tournament_id)
  end
end
