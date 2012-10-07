require "minitest_helper"

describe "SessionsController Acceptance Test" do

  before do
    @omniauth = OmniAuth.config.add_mock(:developer, "info" => {"name" => "Bob Bobson", "email" => "bob@bob.com"})
  end

  describe "existing user" do
    before do
      @service = FactoryGirl.create(:service, :uid => @omniauth['uid'], :provider => @omniauth['provider'])
      @user = @service.user
    end

    it "must authenticate" do
      visit session_path
      click_link "Developer"
      must_have_content "Signed in successfully via Developer"
    end
  end

  describe "new user" do
    it "must show new account creation" do
      visit session_path
      click_link "Developer"
      must_have_content @omniauth["provider"].humanize
      must_have_content @omniauth["uid"]
      must_have_content @omniauth["info"]["name"]
      must_have_content @omniauth["info"]["email"]
      must_have_button "Confirm"
      must_have_button "Cancel"
    end

    it "must authenticate" do
      visit session_path
      click_link "Developer"
      click_button "Confirm"
      must_have_content "Signed in successfully via Developer"
    end

    it "must redirect on cancel" do
      visit session_path
      click_link "Developer"
      click_button "Cancel"
      must_have_content "Sign in via Developer canceled"
    end
  end

  describe "failure" do
    it "must display invalid credentials" do
      OmniAuth.config.mock_auth[:developer] = :invalid_credencials
      visit session_path
      click_link "Developer"
      must_have_content "Invalid credentials"
    end

    it "must display time out" do
      OmniAuth.config.mock_auth[:developer] = :timeout
      visit session_path
      click_link "Developer"
      must_have_content "Authentication timed out"
    end

    it "must display unknown error" do
      OmniAuth.config.mock_auth[:developer] = :something_else
      visit session_path
      click_link "Developer"
      must_have_content "Unknown authentication error"
    end
  end

  describe "logout" do
    it "must log user out" do
      visit session_path
      click_link "Developer"
      click_button "Confirm"
      visit logout_path
      must_have_content "Logged out successfully"
    end
  end
end
