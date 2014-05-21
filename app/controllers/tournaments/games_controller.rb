class Tournaments::GamesController < ApplicationController
  before_filter :find_tournament_and_games
  before_filter :require_owner!

  layout 'tournament_title', :only => [:index]

  def index
    @pending_invite_requests = @tournament.invite_requests.where(invite_id: nil)
  end

  def destroy
    @games.find(params[:id]).destroy
    redirect_to tournament_games_path(@tournament)
  end

  private

  def find_tournament_and_games
    @tournament = Tournament.friendly.find(params[:tournament_id])
    @games = @tournament.games.challenged_or_unconfirmed.order('games.created_at DESC').readonly(false)
  end

  def require_owner!
    unless current_user.id == @tournament.owner_id
      redirect_to tournament_path(@tournament)
    end
  end
end
