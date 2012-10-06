OmniAuth.config.logger = Rails.logger
OmniAuth.config.test_mode = Rails.env.test?

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
end
