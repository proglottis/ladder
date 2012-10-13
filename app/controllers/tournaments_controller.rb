class TournamentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_tournament, :only => [:show, :update, :join]

  def index
    @tournaments = Tournament.participant(current_user)
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
  end

  def join
    rank = @tournament.ranks.with_defaults.build
    rank.user = current_user
    rank.save!
    redirect_to tournament_path(@tournament)
  end

  private

  def find_tournament
    @tournament = Tournament.participant(current_user).find(params[:id])
  end
end
