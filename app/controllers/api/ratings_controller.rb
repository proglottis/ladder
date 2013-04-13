class Api::RatingsController < Api::BaseController
  def index
    respond_with Rating.where(:id => params[:ids])
  end
end
