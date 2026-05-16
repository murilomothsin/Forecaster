OpenWeather::Client.configure do |config|
  config.api_key = Rails.application.credentials.dig(:open_weather, :api_key)
  config.user_agent = 'OpenWeather Ruby Client/1.0'
end
