class Tournaments::InviteRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_tournament, :only => [:index, :update]
  before_action :require_owner!, :only => [:index, :update]

  layout 'tournament_title', :only => [:index]

  def index
    @pending_invite_requests = @tournament.invite_requests.not_completed
  end

  def create
    @tournament = Tournament.where(public: true).friendly.find(params[:tournament_id])
    @invite_request = @tournament.invite_requests.build(user: current_user)
    if @invite_request.save
      Notifications.invite_requested(@invite_request).deliver_now
      redirect_to root_path, :notice => t('tournaments.invite_requests.create.success')
    else
      redirect_to root_path, :notice => t('tournaments.invite_requests.create.failure')
    end
  end

  def update
    @invite_request = InviteRequest.find(params[:id])
    if InviteRequestAcceptor.new(@invite_request, current_user).accept
      redirect_to tournament_invite_requests_path(@tournament),
        :notice => t('tournaments.invite_requests.update.success')
    else
      redirect_to tournament_invite_requests_path(@tournament),
        :notice => t('tournaments.invite_requests.update.failure')
    end
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
