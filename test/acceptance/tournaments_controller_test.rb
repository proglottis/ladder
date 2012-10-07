require "minitest_helper"

describe "TournamentsController Acceptance Test" do

  before do
    @omniauth = OmniAuth.config.add_mock(:developer, "info" => {"name" => "Bob Bobson", "email" => "bob@bob.com"})
    @user = User.create!(:name => "Bob Bobson", :email => "bob@bob.com")
    @service = @user.services.create!(
      :provider => @omniauth['provider'],
      :uid => @omniauth['uid'],
      :name => @omniauth['info'] ? @omniauth['info']['name'] : nil,
      :email => @omniauth['info'] ? @omniauth['info']['email'] : nil)
    visit session_path
    click_link "Developer"
    must_have_content "Signed in successfully via Developer"
  end

  describe "listing" do
    before do
      @tournament1 = @user.tournaments.create! :name => 'Tournament 1'
      @tournament2 = @user.tournaments.create! :name => 'Tournament 2'
    end

    it "must show tournaments" do
      visit tournaments_path
      must_have_link @tournament1.name
      must_have_link @tournament2.name
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

end
