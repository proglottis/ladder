module Api::V1
class GamesController < ApiController
  before_action :require_user!
  before_action :find_game_and_tournament, :only => [:show, :update]

  INCLUDES = ['tournament', 'owner', 'game_ranks', 'game_ranks.player', 'game_ranks.player.user', 'comments']

  wrap_parameters include: [:tournament_id, :confirm, :response, :game_ranks_attributes]

  def index
    @games = Game.participant(current_user).unconfirmed.includes(:tournament, :game_ranks => :user)
    @pending = @games.select { |game| game.game_ranks.detect{|rank| rank.user == current_user}.unconfirmed? }
    render json: @pending, include: INCLUDES
  end

  def show
    render json: @game, include: INCLUDES
  end

  def create
    @tournament = Tournament.participant(current_user).friendly.find(params[:tournament_id])
    @game = GameCreator.new(current_user, @tournament).create(params)
    if game.valid?
      render json: @game, status: :created, include: INCLUDES
    else
      render json: {message: "Bad request"}, status: :bad_request
    end
  end

  def update
    @game.attributes = params.require(:game).permit(:response, :comment, :url)
    CommentService.new(current_user).comment(@game, @game.comment, @game.url, @game.game_ranks.map(&:user))
    if params.has_key?(:confirm)
      GameConfirmer.new(current_user, @game).confirm
    end
    render json: @game, include: INCLUDES
  end

  private

  def find_game_and_tournament
    @game = Game.find(params[:id])
    @tournament = Tournament.with_rated_user(current_user).friendly.find(@game.tournament_id)
  end
end
end
