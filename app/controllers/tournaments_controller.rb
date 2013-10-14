class TournamentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_tournament_and_rating_period_and_player, :only => [:information, :edit, :update, :destroy, :join]
  before_filter :require_owner!, :only => [:edit, :update, :destroy]

  layout 'tournament_title', :only => [:show, :information, :edit]

  def index
    @tournaments = Tournament.participant(current_user).order('tournaments.name ASC')
    @public_tournaments = Tournament.where(public: true).order('tournaments.name ASC')
    @activity = ActivityFeed.new(1.weeks.ago.beginning_of_week, Time.zone.now).for_user(current_user)
  end

  def new
    @tournament = Tournament.where(:owner => current_user).build
  end

  def create
    @tournament = Tournament.where(:owner => current_user).build(params.require(:tournament).permit(:name))
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
    @tournament = Tournament.participant_or_public(current_user).friendly.find(params[:id])
    @rating_period = @tournament.current_rating_period
    @player = @tournament.players.find_by(user_id: current_user)
    @invite_request = @tournament.invite_requests.find_by(user_id: current_user)
    @ratings = @rating_period.ratings.with_defending_tournament.includes(:user).by_rank
    @rating_ranks = @ratings.group_by { |r| view_context.number_with_precision(r.low_rank, :precision => 0)}
    @rating = @ratings.detect { |rating| rating.user_id == current_user.id }
    @pending_games = @tournament.games.where('games.confirmed_at >= ?', @rating_period.period_at)
    @show_actions = @player.present?
  end

  def information
    @page = @tournament.page
  end

  def edit
    @pending_invite_requests = @tournament.invite_requests.where(invite_id: nil)
    @tournament.build_page unless @tournament.page.present?
  end

  def update
    @tournament.slug = nil
    if @tournament.update_attributes(params.require(:tournament).permit(:name, :public, :page_attributes => [:id, :content]))
      redirect_to tournament_path(@tournament)
    else
      render :edit
    end
  end

  def join
    @player = @tournament.players.create!(:user => current_user)
    @rating_period.ratings.with_defaults.create!(:user_id => current_user.id, :player => @player)
    redirect_to tournament_path(@tournament)
  end

  private

  def find_tournament_and_rating_period_and_player
    @tournament = Tournament.participant(current_user).friendly.find(params[:id])
    @rating_period = @tournament.current_rating_period
    @player = @tournament.players.find_by(:user_id => current_user)
  end

  def require_owner!
    unless current_user.id == @tournament.owner_id
      redirect_to tournament_path(@tournament)
    end
  end
end
