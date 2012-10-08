class TournamentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @tournaments = current_user.tournaments
  end

  def new
    @tournament = current_user.tournaments.build
  end

  def create
    @tournament = current_user.tournaments.build params[:tournament]
    if @tournament.save
      redirect_to tournament_path(@tournament)
    else
      render :new
    end
  end

  def show
    @tournament = current_user.tournaments.find params[:id]
  end

  def join
    @tournament = current_user.tournaments.find params[:id]
    rank = @tournament.ranks.with_defaults.build
    rank.user = current_user
    rank.save!
    redirect_to tournament_path(@tournament)
  end
end
