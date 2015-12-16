class InviteRequestAcceptor
  def initialize(invite_request, acceptor)
    @invite_request = invite_request
    @acceptor = acceptor
    @tournament = invite_request.tournament
    @user = invite_request.user
  end

  def accept
    @tournament.with_lock do
      @invite_request.lock!
      return if @invite_request.completed?

      invite = @tournament.invites.build(email: @user.email, owner: @acceptor)
      if invite.save
        @invite_request.update_attributes!(invite: invite)
        Notifications.tournament_invitation(invite).deliver_now
        invite
      end
    end
  end
end
