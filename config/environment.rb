# Load the Rails application.
require File.expand_path('../application', __FILE__)

APP_VERSION = `git describe --always`.strip unless defined? APP_VERSION

# Initialize the Rails application.
Ladder::Application.initialize!
