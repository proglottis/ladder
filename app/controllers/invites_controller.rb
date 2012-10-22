class InvitesController < ApplicationController
  before_filter :authenticate_user!

  def show
    @tournament = Tournament.find(params[:tournament_id])
    @invite = @tournament.invites.available.find_by_code!(params[:id])
  end

  def update
    @tournament = Tournament.find(params[:tournament_id])
    @invite = @tournament.invites.available.find_by_code!(params[:id])
    @invite.user = current_user
    if @invite.save
      redirect_to tournament_path(@tournament)
    else
      render :show
    end
  end

  def new
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
    @invite = @tournament.invites.build
  end

  def create
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
    @invite = @tournament.invites.build(params.require(:invite).permit(:email))
    if @invite.save
      InviteMailer.invite_email(@invite).deliver
      redirect_to tournament_path(@tournament)
    else
      render :new
    end
  end
end
