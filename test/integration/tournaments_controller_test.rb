require "minitest_helper"

describe "TournamentsController Integration Test" do

  before do
    @service = login_service
  end

  describe "listing" do
    before do
      @tournaments = create_list(:tournament, 5, :owner => @service.user)
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
      @tournament = create(:tournament, :owner => @service.user)
    end

    it "must let owner join" do
      visit tournament_path(@tournament)
      click_link "Join"
      wont_have_content "You are not participating"
    end
  end
end
