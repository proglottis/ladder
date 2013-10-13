class Tournaments::InviteRequestsController < ApplicationController
  before_filter :authenticate_user!

  def show
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

end
