class InvitesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_invite_for_tournament, :only => [:show, :update]
  before_filter :find_tournament_with_current_user, :only => [:new, :create]

  layout 'tournaments'

  def show
  end

  def update
    if @invite.update_attributes(:user => current_user)
      redirect_to tournament_path(@tournament)
    else
      render :show
    end
  end

  def new
    @invite = @tournament.invites.build
  end

  def create
    @invite = @tournament.invites.build(params.require(:invite).permit(:email))
    @invite.owner = current_user
    if @invite.save
      InviteMailer.invite_email(@invite).deliver
      redirect_to tournament_path(@tournament)
    else
      render :new
    end
  end

  private

  def find_invite_for_tournament
    @tournament = Tournament.find(params[:tournament_id])
    @invite = @tournament.invites.available.find_by_code!(params[:id])
  end

  def find_tournament_with_current_user
    @tournament = Tournament.participant(current_user).find(params[:tournament_id])
  end
end
