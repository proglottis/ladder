module Api::V1

class TournamentsController < ApiController
  before_filter :authenticate_user!

  def index
    render json: Tournament.participant(current_user)
  end

  def show
    render json: Tournament.participant_or_public(current_user).friendly.find(params[:id])
  end
end

end
