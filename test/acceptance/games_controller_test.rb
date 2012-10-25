require "minitest_helper"

describe "GamesController Acceptance Test" do

  before do
    @omniauth = OmniAuth.config.add_mock(:developer, "info" => {"name" => "Bob Bobson", "email" => "bob@bob.com"})
    @service = create(:service, :uid => @omniauth['uid'], :provider => @omniauth['provider'])
    @user = @service.user
    visit session_path
    click_link "Developer"
    must_have_content "Signed in successfully via Developer"
    @tournament = create(:tournament)
    @rank1 = create(:rank, :tournament => @tournament, :user => @user)
    @rank2 = create(:rank, :tournament => @tournament)
  end

  describe "creation" do
    it "must be created" do
      visit tournament_path @tournament
      click_link "Game"
      click_button "Create"
      must_have_content @rank1.user.name
      must_have_content @rank2.user.name
      must_have_link "Confirm"
      must_have_content "Unconfirmed"
    end
  end

  describe "confirming" do
    it "must be confirmed" do
      visit tournament_path @tournament
      click_link "Game"
      click_button "Create"
      click_link "Confirm"
      must_have_content "Confirmed"
    end
  end

end
