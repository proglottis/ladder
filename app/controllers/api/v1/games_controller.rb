module Api::V1
class GamesController < ApiController
  before_filter :require_user!

  wrap_parameters include: [:tournament_id, :game_ranks_attributes]

  def index
    @games = Game.participant(current_user).unconfirmed.includes(:tournament, :game_ranks => :user)
    @pending = @games.select { |game| game.game_ranks.detect{|rank| rank.user == current_user}.unconfirmed? }
    render json: @pending
  end

  def show
    @game = Game.find(params[:id])
    @tournament = Tournament.with_rated_user(current_user).friendly.find(@game.tournament_id)
    render json: @game
  end

  def create
    @tournament = Tournament.participant(current_user).friendly.find(params[:tournament_id])
    if game = GameCreator.new(current_user, @tournament).create(params)
      render json: game, status: :created
    else
      render json: {message: "Bad request"}, status: :bad_request
    end
  end

  def update
    @game.attributes = params.require(:game).permit(:response, :comment)
    CommentService.new(current_user).comment(@game, @game.comment, @game.game_ranks.map(&:user))
    if params.has_key?(:confirm)
      GameConfirmer.new(current_user, @game).confirm
    end
    render json: @game
  end
end
end
