class RatingPeriodsController < ApplicationController
  respond_to :json

  def show
    respond_with RatingPeriod.find(params[:id])
  end
end
