class TournamentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_tournament, :only => [:show, :edit, :update, :join]
  before_filter :require_owner!, :only => [:edit, :update]

  layout 'tournament_title', :only => [:show, :edit]

  def index
    @tournaments = Tournament.participant(current_user).order('tournaments.name ASC')
    @games = Game.with_participant(current_user).order('games.updated_at DESC').page(params[:page]).per(10)
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
    @glicko2_ratings = @tournament.glicko2_ratings.includes(:user).by_rank
    @rating_ranks = @glicko2_ratings.group_by { |r| view_context.number_with_precision(r.low_rank, :precision => 0)}
    @pending = @tournament.games.where('games.confirmed_at >= ?', Time.zone.now.beginning_of_week)
    @challenges = @tournament.challenges.active
  end

  def edit
  end

  def update
    if @tournament.update_attributes(params.require(:tournament).permit(:name))
      redirect_to tournament_path(@tournament)
    else
      render :edit
    end
  end

  def join
    @tournament.glicko2_ratings.with_defaults.create(:user => current_user)
    redirect_to tournament_path(@tournament)
  end

  private

  def find_tournament
    @tournament = Tournament.participant(current_user).find(params[:id])
  end

  def require_owner!
    unless current_user.id == @tournament.owner_id
      redirect_to tournament_path(@tournament)
    end
  end
end
