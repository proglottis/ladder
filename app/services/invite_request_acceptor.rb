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

      @invite_request.update_attributes!(completed_at: Time.zone.now)
      TournamentJoiner.new(@tournament, @user).join
      Notifications.invite_request_accepted(@invite_request).deliver_now
    end
  end
end
