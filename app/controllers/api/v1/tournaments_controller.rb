module Api::V1

class TournamentsController < ApiController
  def index
    if user_logged_in?
      render json: Tournament.participant(current_user), each_serializer: TournamentListSerializer
    else
      render json: Tournament.where(public: true), each_serializer: TournamentListSerializer
    end
  end

  def show
    if user_logged_in?
      render json: Tournament.participant_or_public(current_user).friendly.find(params[:id])
    else
      render json: Tournament.where(public: true).friendly.find(params[:id])
    end
  end
end

end
