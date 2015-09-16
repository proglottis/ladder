class GamesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_game_and_tournament, :only => [:show, :update]

  def index
    @games = Game.participant(current_user).challenged_or_unconfirmed.includes(:tournament, :game_ranks => :user)
    @unconfirmed, @pending = @games.partition { |game| game.game_ranks.detect{|rank| rank.user == current_user}.confirmed? }
  end

  def new
    @tournament = Tournament.with_rated_user(current_user).friendly.find(params[:tournament_id])
    @other_user = User.friendly.find(params[:user_id])
    @game = @tournament.games.build
    @game.game_ranks.build :player => @tournament.players.active.find_by!(user_id: current_user), :position => 1
    @game.game_ranks.build :player => @tournament.players.active.find_by!(user_id: @other_user), :position => 2
  end

  def create
    @tournament = Tournament.with_rated_user(current_user).friendly.find(params[:tournament_id])
    if game = GameCreator.new(current_user, @tournament).create(params)
      redirect_to game_path(game)
    else
      render :new
    end
  end

  def show
    @game_ranks = @game.game_ranks.includes(:user)
    @current_game_rank = @game_ranks.detect {|game_rank| game_rank.user.id == current_user.id }
    @comments = @game.comments
    @championship = @game.match.try(:championship)
  end

  def update
    @game.attributes = params.require(:game).permit(:response, :comment)
    CommentService.new(current_user).comment(@game, @game.comment, @game.game_ranks.map(&:user))
    if params.has_key?(:confirm)
      GameConfirmer.new(current_user, @game).confirm
    elsif params.has_key?(:respond)
      @game.defender_response!
      if @game.unconfirmed?
        @game.game_ranks.each do |game_rank|
          Notifications.game_confirmation(game_rank.user, @game).deliver_now unless game_rank.confirmed?
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
