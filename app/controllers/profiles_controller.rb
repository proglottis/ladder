class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user

  def show
    @activity = ActivityFeed.new(1.weeks.ago.beginning_of_week, Time.zone.now).for_user(@user, current_user)
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
