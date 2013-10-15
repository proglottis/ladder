class Tournaments::InviteRequestsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_tournament, :only => [:index, :update]
  before_filter :require_owner!, :only => [:update]

  layout 'tournament_title', :only => [:index]

  def index
    @pending_invite_requests = @tournament.invite_requests.where(invite_id: nil)
  end

  def create
    @tournament = Tournament.where(public: true).friendly.find(params[:tournament_id])
    @invite_request = @tournament.invite_requests.build(user: current_user)
    if @invite_request.save
      redirect_to root_path, :notice => t('tournaments.invite_requests.create.success')
    else
      redirect_to root_path, :notice => t('tournaments.invite_requests.create.failure')
    end
  end

  def update
    @invite_request = InviteRequest.find(params[:id])
    @invite = @tournament.invites.build(email: @invite_request.user.email, owner: current_user)
    if @invite.save
      @invite_request.update_attributes!(invite_id: @invite)
      Notifications.tournament_invitation(@invite).deliver
      redirect_to tournament_invite_requests_path(@tournament),
        :notice => t('tournaments.invites.create.success', :email => @invite.email)
    else
      redirect_to tournament_invite_requests_path(@tournament),
        :notice => t('tournaments.invites.create.failure', :email => @invite.email)
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
