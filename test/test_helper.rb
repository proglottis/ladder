ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "capybara"
require "capybara/rspec/matchers"
require "minitest/rails/capybara"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryGirl::Syntax::Methods

  before do
    ActionMailer::Base.deliveries.clear
  end

  after do
    Timecop.return
  end

  def login_service
    service = create(:service)
    OmniAuth.config.add_mock(:developer, "uid" => service.uid, "info" => {"name" => service.name, "email" => service.email})
    visit session_path
    click_link "Developer"
    must_have_content I18n.t('sessions.create.success', :provider => 'Developer')
    service
  end
end

class ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers
  include Capybara::RSpecMatchers
  include Capybara::DSL
end

class MiniTest::Spec
  include FactoryGirl::Syntax::Methods
end
