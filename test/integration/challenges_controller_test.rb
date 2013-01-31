require "minitest_helper"

describe "ChallengesController Integration Test" do

  before do
    @service = login_service
    @tournament = create(:tournament)
    @user2 = create(:user)
    @rating1 = create(:rating, :tournament => @tournament, :user => @service.user)
    @rating2 = create(:rating, :tournament => @tournament, :user => @user2)
  end

  describe "creation" do
    it "must be created" do
      visit tournament_path @tournament
      all('a', :text => 'Challenge').last.click
      click_button "Create"
      must_have_content @rating1.user.name
      must_have_content @rating2.user.name
      must_have_content "This challenge expires"
      Challenge.last.challenger.must_equal @service.user
      Challenge.last.defender.must_equal @user2
    end

    it "must send challenge email" do
      visit tournament_path @tournament
      all('a', :text => 'Challenge').last.click
      click_button "Create"
      ActionMailer::Base.deliveries.length.must_equal 1
      email = ActionMailer::Base.deliveries.first
      email.to.must_equal [@user2.email]
    end
  end

  describe "responding" do
    before do
      @challenge = create(:challenge, :tournament => @tournament, :challenger => @user2, :defender => @service.user)
    end

    it "must show response page" do
      visit challenge_path(@challenge)
      must_have_button "Respond"
    end

    it "must respond" do
      visit challenge_path(@challenge)
      choose "I won"
      click_button "Respond"
      must_have_content "Unconfirmed"
      @challenge.reload.game.wont_equal nil
    end

    it "must send confirm game email" do
      visit challenge_path(@challenge)
      choose "I won"
      click_button "Respond"
      ActionMailer::Base.deliveries.length.must_equal 1
      email = ActionMailer::Base.deliveries.first
      email.to.must_equal [@user2.email]
    end
  end

end
