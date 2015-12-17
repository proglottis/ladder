class InviteAcceptor
  def initialize(invite, user)
    @invite = invite
    @user = user
    @tournament = @invite.tournament
  end

  def accept
    @tournament.with_lock do
      if TournamentJoiner.new(@tournament, @user).join
        @invite.update_attributes!(:user => @user)
      end
    end
  end
end
