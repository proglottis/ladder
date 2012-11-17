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
    @tournament = current_user.tournaments.build(params.require(:tournament).permit(:name))
    if @tournament.save
      redirect_to tournament_path(@tournament)
    else
      render :new
    end
  end

  def show
    @ranks = @tournament.ranks.includes(:user).by_rank
    @elo_ratings = @tournament.elo_ratings.includes(:user).by_rating
  end

  def join
    @rank = @tournament.ranks.with_defaults.build(:user => current_user)
    @rank.save
    @tournament.elo_ratings.with_defaults.create(:user => current_user)
    redirect_to tournament_path(@tournament)
  end

  private

  def find_tournament
    @tournament = Tournament.participant(current_user).find(params[:id])
  end
end
