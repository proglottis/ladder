require "minitest_helper"

describe InviteMailer do
  it "#invite_email" do
    @tournament = create(:tournament)
    @invite = create(:invite, :tournament => @tournament)
    mail = InviteMailer.invite_email @invite
    mail.subject.must_equal "You have been invited"
    mail.to.must_equal [@invite.email]
    mail.body.encoded.must_match @tournament.name
    mail.body.encoded.must_match @invite.code
  end
end
