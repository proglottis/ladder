class Tournaments::GamesController < ApplicationController
  before_filter :find_tournament
  before_filter :require_owner!

  layout 'tournament_title', :only => [:index]

  def index
    @pending_invite_requests = @tournament.invite_requests.where(invite_id: nil)
    @games = @tournament.games.challenged_or_unconfirmed
  end

  private

  def find_tournament
    @tournament = Tournament.friendly.find(params[:tournament_id])
  end

  def require_owner!
    unless current_user.id == @tournament.owner_id
      redirect_to tournament_path(@tournament)
    end
  end
end
