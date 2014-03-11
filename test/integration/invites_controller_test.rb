require "test_helper"

describe "InvitesController Integration Test" do

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

    describe "not a player" do
      before do
        @player.destroy
      end

      it "must refuse sending an invite" do
        visit new_tournament_invite_path @tournament
        must_have_content 'Please join the tournament before inviting other players'
      end
    end

    it "must create invite" do
      visit new_tournament_invite_path @tournament
      fill_in Invite.human_attribute_name("email"), :with => "user@example.com"
      click_button Invite.model_name.human
      must_have_content @tournament.name
      Invite.last.email.must_equal "user@example.com"
    end

    it "must send invite email" do
      visit new_tournament_invite_path @tournament
      fill_in Invite.human_attribute_name("email"), :with => "user@example.com"
      click_button Invite.model_name.human
      must_have_content @tournament.name
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
      must_have_content @tournament.name
      must_have_button I18n.t("helpers.submit.invite.update")
      must_have_link I18n.t("helpers.cancel_link")
    end

    it "must join player" do
      visit tournament_invite_path @tournament, @invite
      click_button I18n.t("helpers.submit.invite.update")
      must_have_content @tournament.name
      must_have_content @user.name
    end
  end

end
