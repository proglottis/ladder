class InviteMailer < ActionMailer::Base
  default from: "ladder@nothing.co.nz"

  def invite_email(invite)
    @invite = invite
    @tournament = invite.tournament
    mail(:to => invite.email, :subject => "You have been invited")
  end
end
