module Api::V1

class TournamentsController < ApiController
  def index
    if user_logged_in?
      render json: Tournament.participant(current_user), include: []
    else
      render json: Tournament.where(public: true), include: []
    end
  end

  def show
    if user_logged_in?
      @tournament = Tournament.participant_or_public(current_user).friendly.find(params[:id])
    else
      @tournament = Tournament.where(public: true).friendly.find(params[:id])
    end
    render json: @tournament, include: ['players', 'players.user']
  end
end

end
