class RatingsController < ApplicationController
  respond_to :json

  def index
    respond_with Rating.where(:id => params[:ids])
  end
end
