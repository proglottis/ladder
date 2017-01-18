require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ladder
  VERSION = "1.6.12"

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'Auckland'
    config.action_mailer.default_url_options = { :host => 'ladders.pw', :protocol => 'https' }
    config.exceptions_app = self.routes
    config.active_job.queue_adapter = :sidekiq
  end
end
