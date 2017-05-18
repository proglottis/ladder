require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  def login_as(user)
    service = create(:service, user: user)
    OmniAuth.config.add_mock("developer", "uid" => service.uid, "info" => {"name" => service.name, "email" => service.email})
    visit session_path
    click_link "Developer"
    assert_text I18n.t('sessions.create.success', :provider => 'Developer')
    service
  end

  def login_service
    login_as(create(:user))
  end
end
