require "minitest_helper"

describe "TournamentsController Acceptance Test" do

  before do
    @omniauth = OmniAuth.config.add_mock(:developer, "info" => {"name" => "Bob Bobson", "email" => "bob@bob.com"})
    @service = create(:service, :uid => @omniauth['uid'], :provider => @omniauth['provider'])
    @user = @service.user
    visit session_path
    click_link "Developer"
    must_have_content "Signed in successfully via Developer"
  end

  describe "listing" do
    before do
      @tournaments = create_list(:tournament, 5, :owner => @user)
    end

    it "must show tournaments" do
      visit tournaments_path
      @tournaments.each do |tournament|
        must_have_link tournament.name
      end
      must_have_link "Start tournament"
    end
  end

  describe "creation" do
    it "must be created" do
      visit tournaments_path
      click_link "Start"
      fill_in 'Name', :with => 'Test Tournament'
      click_button 'Start'
      must_have_content 'Test Tournament'
    end

    it "must fail with empty name" do
      visit tournaments_path
      click_link "Start"
      click_button 'Start'
      must_have_content 'Start tournament'
    end
  end

  describe "joining" do
    before do
      @tournament = create(:tournament, :owner => @user)
    end

    it "must let owner join" do
      visit tournament_path(@tournament)
      click_link "join"
      wont_have_content "You are not participating"
    end
  end
end
