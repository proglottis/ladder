if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotifier,
    :sender_address => 'ladders@ladders.pw',
    :exception_recipients => ENV['LADDER_SERVICE_EMAIL'],
    :ignore_exceptions => ExceptionNotifier.default_ignore_exceptions
end
