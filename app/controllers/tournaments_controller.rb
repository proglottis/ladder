class TournamentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :information]
  before_filter :find_tournament_and_rating_period_and_player, :only => [:edit, :update, :destroy, :join]
  before_filter :require_owner!, :only => [:edit, :update, :destroy]

  layout 'tournament_title', :only => [:show, :information, :edit]

  def index
    @tournaments = Tournament.participant(current_user).order('tournaments.name ASC')
    @public_tournaments = Tournament.where(public: true).order('tournaments.name ASC')
    @page = [1, params[:page].to_i].max
    @start_on = ((@page - 1) * 2).weeks.ago.beginning_of_week.to_date
    @end_on = @start_on + 2.weeks
    @activity = ActivityFeed.new(@start_on, @end_on).for_user(current_user)
  end

  def new
    @tournament = Tournament.where(:owner => current_user).build
  end

  def create
    @tournament = Tournament.where(:owner => current_user).build(params.require(:tournament).permit(:name, :ranking_type))
    if @tournament.save
      @tournament.rating_periods.create!(:period_at => Time.zone.now.beginning_of_week)
      redirect_to tournament_path(@tournament)
    else
      flash.notice = I18n.t("tournament.creation_failed")
      render :new
    end
  end

  def destroy
    @tournament.destroy
    redirect_to tournaments_path, :notice => t('tournaments.destroy.success', :name => @tournament.name)
  end

  def show
    if user_logged_in?
      @tournament = Tournament.participant_or_public(current_user).friendly.find(params[:id])
    else
      @tournament = Tournament.where(public: true).friendly.find(params[:id])
    end
    @rating_period = @tournament.current_rating_period
    @player = @tournament.players.active.find_by(user_id: current_user)
    @ratings = @rating_period.ratings.includes(:user, {:rating_period => :tournament}).active_by_position
    @rating_ranks = @ratings.group_by { |rating| rating.player.position }
    @rating = @ratings.detect { |rating| rating.player_id == @player.id } if @player.present?
    @pending_games = @tournament.games.confirmed_between(@rating_period.period_at, Time.zone.now)
    @show_actions = @player.present?
    @championship = @tournament.championships.active
  end

  def information
    if user_logged_in?
      @tournament = Tournament.participant_or_public(current_user).friendly.find(params[:id])
    else
      @tournament = Tournament.where(public: true).friendly.find(params[:id])
    end
    @page = @tournament.page
  end

  def edit
    @tournament.build_page unless @tournament.page.present?
  end

  def update
    @tournament.slug = nil

    original_owner_id = @tournament.owner_id

    if @tournament.update_attributes(params.require(:tournament).permit(:name, :public, :owner_id, :page_attributes => [:id, :content]))
      if original_owner_id != @tournament.owner_id
        flash[:notice] = I18n.t("tournament.ownership_transferred")
      end

      redirect_to tournament_path(@tournament)
    else
      render :edit
    end
  end

  def join
    TournamentJoiner.new(@tournament, current_user).join
    redirect_to tournament_path(@tournament)
  end

  private

  def find_tournament_and_rating_period_and_player
    @tournament = Tournament.participant(current_user).friendly.find(params[:id])
    @rating_period = @tournament.current_rating_period
    @player = @tournament.players.active.find_by(:user_id => current_user)
  end

  def require_owner!
    unless current_user.id == @tournament.owner_id
      redirect_to tournament_path(@tournament)
    end
  end
end
