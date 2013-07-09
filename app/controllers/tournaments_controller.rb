class TournamentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_tournament_and_rating_period, :only => [:show, :information, :edit, :update, :destroy, :join]
  before_filter :require_owner!, :only => [:edit, :update, :destroy]

  layout 'tournament_title', :only => [:show, :information, :edit]

  def index
    @tournaments = Tournament.participant(current_user).order('tournaments.name ASC')
    @activity = ActivityFeed.new(current_user).between_dates(1.weeks.ago.beginning_of_week, Time.zone.now)
  end

  def new
    @tournament = current_user.tournaments.build
  end

  def create
    @tournament = current_user.tournaments.build(params.require(:tournament).permit(:name))
    if @tournament.save
      @tournament.rating_periods.create!(:period_at => Time.zone.now.beginning_of_week)
      redirect_to tournament_path(@tournament)
    else
      render :new
    end
  end

  def destroy
    @tournament.destroy
    redirect_to tournaments_path, :notice => t('tournaments.destroy.success', :name => @tournament.name)
  end

  def show
    @ratings = @rating_period.ratings.with_defending_tournament.includes(:user).by_rank
    @rating_ranks = @ratings.group_by { |r| view_context.number_with_precision(r.low_rank, :precision => 0)}
    @rating = @ratings.detect { |rating| rating.user_id == current_user.id }
    @pending = @tournament.games.where('games.confirmed_at >= ?', @rating_period.period_at)
    @positions = @tournament.ordered_positions_per_user
    @show_actions = @tournament.has_user?(current_user)
  end

  def information
    @page = @tournament.page
  end

  def edit
    @tournament.build_page unless @tournament.page.present?
  end

  def update
    if @tournament.update_attributes(params.require(:tournament).permit(:name, :page_attributes => [:id, :content]))
      redirect_to tournament_path(@tournament)
    else
      render :edit
    end
  end

  def join
    @rating_period.ratings.with_defaults.create(:user => current_user)
    redirect_to tournament_path(@tournament)
  end

  private

  def find_tournament_and_rating_period
    @tournament = Tournament.participant(current_user).find(params[:id])
    @rating_period = @tournament.current_rating_period
  end

  def require_owner!
    unless current_user.id == @tournament.owner_id
      redirect_to tournament_path(@tournament)
    end
  end
end
