class TournamentsController < ApplicationController
  respond_to :json
  before_filter :authenticate_user!

  def index
    respond_with Tournament.participant(current_user)
  end

  def show
    respond_with Tournament.participant(current_user).find(params[:id])
  end

  def create
    @tournament = current_user.tournaments.create(params.require(:tournament).permit(:name))
    @tournament.rating_periods.create!(:period_at => Time.zone.now.beginning_of_week) unless @tournament.new_record?
    respond_with @tournament
  end
end
