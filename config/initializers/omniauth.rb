OmniAuth.config.logger = Rails.logger
OmniAuth.config.test_mode = Rails.env.test?

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {:access_type => 'online', :approval_prompt => ''}
end
