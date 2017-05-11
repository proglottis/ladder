require "application_system_test_case"

class InvitesTest < ApplicationSystemTestCase
  before do
    @service = login_service
    @tournament = create(:started_tournament)
    @player = create(:player, :user => @service.user, :tournament => @tournament)
    @user = @service.user
  end

  describe "inviting" do
    before do
      @tournament.update_attributes!(:owner => @user)
    end

    it "must create invite" do
      visit new_tournament_invite_path @tournament
      fill_in Invite.human_attribute_name("email"), :with => "user@example.com"
      click_button Invite.model_name.human
      assert_text @tournament.name
      Invite.last.email.must_equal "user@example.com"
    end

    it "must send invite email" do
      visit new_tournament_invite_path @tournament
      fill_in Invite.human_attribute_name("email"), :with => "user@example.com"
      click_button Invite.model_name.human
      assert_text @tournament.name
      ActionMailer::Base.deliveries.length.must_equal 1
      email = ActionMailer::Base.deliveries.first
      email.to.must_equal ["user@example.com"]
    end
  end

  describe "joining" do
    before do
      @invite = create(:invite, :tournament => @tournament)
    end

    it "must show invite page" do
      visit tournament_invite_path @tournament, @invite
      assert_text @tournament.name
      assert_button I18n.t("helpers.submit.invite.update")
      assert_link I18n.t("helpers.cancel_link")
    end

    it "must join player" do
      visit tournament_invite_path @tournament, @invite
      click_button I18n.t("helpers.submit.invite.update")
      assert_text @tournament.name
      assert_text @user.name
    end
  end

end
