require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  before do
    @omniauth = OmniAuth.config.add_mock('developer', "info" => {"name" => "Bob Bobson", "email" => "bob@bob.com"})
  end

  describe "existing user" do
    before do
      @service = create(:service, :uid => @omniauth['uid'], :provider => @omniauth['provider'])
      @user = @service.user
    end

    it "must authenticate" do
      visit session_path
      click_link "Developer"
      assert_text I18n.translate('sessions.create.success', :provider => 'Developer')
    end

    it "must redirect back after authentication" do
      visit games_path
      click_link "Developer"
      assert_text Game.model_name.human.pluralize
    end

    it "must update info after authentication" do
      @omniauth['info']['image'] = 'http://localhost:3000'
      visit session_path
      click_link "Developer"
      assert_text I18n.translate('sessions.create.success', :provider => 'Developer')
      @service.reload.image_url.must_equal 'http://localhost:3000'
    end
  end

  describe "new user" do
    it "must show new account creation" do
      visit session_path
      click_link "Developer"
      assert_text @omniauth["provider"].humanize
      assert_text @omniauth["uid"]
      assert_text @omniauth["info"]["name"]
      assert_text @omniauth["info"]["email"]
    end

    it "must authenticate" do
      visit session_path
      click_link "Developer"
      click_button I18n.translate('sessions.new.confirm')
      assert_text I18n.translate('sessions.create.success', :provider => 'Developer')
    end

    it "must redirect on cancel" do
      visit session_path
      click_link "Developer"
      click_button I18n.translate('helpers.cancel_link')
      assert_text I18n.translate('sessions.create.canceled', :provider => 'Developer')
    end
  end

  describe "failure" do
    it "must display invalid credentials" do
      OmniAuth.config.mock_auth[:developer] = :invalid_credentials
      visit session_path
      click_link "Developer"
      assert_text I18n.translate('sessions.failure.invalid')
    end

    it "must display time out" do
      OmniAuth.config.mock_auth[:developer] = :timeout
      visit session_path
      click_link "Developer"
      assert_text I18n.translate('sessions.failure.timed_out')
    end

    it "must display unknown error" do
      OmniAuth.config.mock_auth[:developer] = :something_else
      visit session_path
      click_link "Developer"
      assert_text I18n.translate('sessions.failure.unknown')
    end
  end

  describe "logout" do
    it "must log user out" do
      visit session_path
      click_link "Developer"
      click_button I18n.translate('sessions.new.confirm')
      visit logout_path
      assert_text I18n.translate('sessions.destroy.success')
    end
  end
end
