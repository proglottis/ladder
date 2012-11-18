class HomesController < ApplicationController
  def show
    if user_logged_in?
      @games = Game.with_participant(current_user).order('games.updated_at DESC').page(params[:page]).per(10)
    end
  end
end
