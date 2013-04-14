class GamesController < ApplicationController
  respond_to :json
  before_filter :authenticate_user!

  def index
    respond_with Game.with_participant(current_user).order('games.updated_at DESC').page(params[:page]).per(10)
  end
end
