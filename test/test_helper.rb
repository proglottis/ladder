ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryGirl::Syntax::Methods
  include ActiveJob::TestHelper

  before do
    ActionMailer::Base.deliveries.clear
  end
end

class ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers
  include Capybara::DSL

  def login_service
    service = create(:service)
    OmniAuth.config.add_mock("developer", "uid" => service.uid, "info" => {"name" => service.name, "email" => service.email})
    visit session_path
    click_link "Developer"
    assert_page_has_content I18n.t('sessions.create.success', :provider => 'Developer')
    service
  end
end
