if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    :email => {
      :sender_address => 'ladders@ladders.pw',
      :exception_recipients => ENV['SERVICE_EMAIL']
    }
end
