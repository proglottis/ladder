class GamesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_tournament

  def new
  end

  private

  def find_tournament
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
  end
end
