class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user

  def show
    @games = Game.with_participant(current_user, @user).includes(:tournament, :game_ranks => :user).order('games.updated_at DESC').page(params[:page]).per(10)
    @tournaments = Tournament.with_rated_user(current_user, @user).order('tournaments.name ASC')
  end

  def history
    @tournament = Tournament.with_rated_user(current_user, @user).find(params[:tournament_id])
    @users = current_user == @user ? [current_user] : [current_user, @user]
    @series = @users.map do |user|
      {
        :name => user.name,
        :data => @tournament.ratings.where(:user_id => user).joins(:rating_period).order('rating_periods.period_at').select('ratings.*, rating_periods.period_at')
      }
    end

    respond_to do |format|
      format.json { render :json => @series }
    end
  end

  private

  def find_user
    @user = User.find(params[:id])
  end
end
