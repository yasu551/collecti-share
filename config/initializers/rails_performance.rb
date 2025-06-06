if defined?(RailsPerformance)
  RailsPerformance.setup do |config|
    config.redis = Redis.new # optional, will use Rails.cache otherwise
    config.duration = 4.hours # store requests for 4 hours
    config.enabled = Rails.env.production?
    config.http_basic_authentication_enabled = true
    config.http_basic_authentication_user_name = 'admin'
    config.http_basic_authentication_password = 'password'
  end
end
