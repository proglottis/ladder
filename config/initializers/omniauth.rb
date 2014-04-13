OmniAuth.config.logger = Rails.logger
OmniAuth.config.test_mode = Rails.env.test?

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :google_oauth2, Rails.application.secrets.google_key, Rails.application.secrets.google_secret, {:access_type => 'online', :approval_prompt => ''}
end
