class Tournaments::InvitesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_invite_for_tournament, :only => [:show, :update]
  before_filter :find_tournament, :only => [:new, :create]

  layout 'tournament_title', :only => [:new, :create]

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
      Notifications.tournament_invitation(@invite).deliver_now
      redirect_to tournament_path(@tournament),
        :notice => t('tournaments.invites.create.success', :email => @invite.email)
    else
      render :new
    end
  end

  private

  def find_invite_for_tournament
    @tournament = Tournament.friendly.find(params[:tournament_id])
    @invite = @tournament.invites.available.find_by_code!(params[:id])
  end

  def find_tournament
    @tournament = Tournament.participant(current_user).friendly.find(params[:tournament_id])
  end
end
