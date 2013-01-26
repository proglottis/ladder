class ProfilesController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = User.find(params[:id])
    @games = Game.with_participant(current_user, @user).order('games.updated_at DESC').page(params[:page]).per(10)
    @tournaments = Tournament.with_rated_user(current_user, @user).order('tournaments.name ASC')
  end
end
