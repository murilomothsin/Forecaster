
class Weather
  def initialize(units: 'metric')
    @options = { units: units }
    @client = OpenWeather::Client.new
  end

  def current_weather(zip_code)
    cache_hit = true
    response = Rails.cache.fetch("weather/#{zip_code}/unit/#{@options[:units]}", expires_in: 30.minutes) do
      cache_hit = false
      @client.current_zip(zip_code, 'US', @options)
    end

    [cache_hit, response]
  end
end
