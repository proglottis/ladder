module Api::V1
class GamesController < ApiController
  before_filter :authenticate_user!

  wrap_parameters include: [:tournament_id, :game_ranks_attributes]

  def create
    @tournament = Tournament.participant(current_user).friendly.find(params[:tournament_id])
    if game = GameCreator.new(current_user, @tournament).create(params)
      render json: game, status: :created
    else
      render json: {message: "Bad request"}, status: :bad_request
    end
  end
end
end
