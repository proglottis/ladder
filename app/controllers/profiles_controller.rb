class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user

  def show
    @page = [1, params[:page].to_i].max
    @start_on = ((@page - 1) * 2).weeks.ago.beginning_of_week.to_date
    @end_on = @start_on + 2.weeks
    @activity = ActivityFeed.new(@start_on, @end_on).for_user(@user, current_user)
    @tournaments = Tournament.with_rated_user(current_user, @user).order('tournaments.name ASC')
  end

  def history
    @tournament = Tournament.with_rated_user(current_user, @user).friendly.find(params[:tournament_id])
    @users = current_user == @user ? [current_user] : [current_user, @user]
    @series = @users.map do |user|
      {
        :key => user.name,
        :values => @tournament.ratings.joins(:user).merge(User.where(:id => user)).joins(:rating_period).order('rating_periods.period_at').select('ratings.*, rating_periods.period_at')
      }
    end

    respond_to do |format|
      format.json { render :json => @series }
    end
  end

  private

  def find_user
    @user = User.friendly.find(params[:id])
  end
end
