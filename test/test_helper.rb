ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/spec"
require "capybara/rails"

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryGirl::Syntax::Methods

  def setup
    ActionMailer::Base.deliveries.clear
  end

  def teardown
    Timecop.return
  end

  class << self
    remove_method :describe
  end

  extend MiniTest::Spec::DSL

  register_spec_type self do |desc|
    desc.is_a? Class
  end
end

class ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers
  include Capybara::DSL

  register_spec_type self do |desc|
    desc =~ /Integration Test/
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
