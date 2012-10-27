class HomesController < ApplicationController
  def show
    if user_logged_in?
      @game_ranks = GameRank.not_confirmed.with_participant(current_user)
    end
  end
end
