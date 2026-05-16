class WeatherService
  def initialize(units: "metric")
    @units = units
    @client = OpenWeatherClient.new
  end

  def search_by_zip(zip_code, country_code = "US")
    geo = @client.geocode_zip(zip_code, country_code)
    fetch_weather(geo["lat"], geo["lon"])
  end

  def search_by_city(city, country_code = nil)
    results = @client.geocode_city(city, country_code)
    raise OpenWeatherClient::ApiError.new("City not found", code: 404) if results.empty?

    geo = results.first
    fetch_weather(geo["lat"], geo["lon"])
  end

  private

  def fetch_weather(lat, lon)
    cache_hit = true

    current = Rails.cache.fetch("weather/current/#{lat}/#{lon}/#{@units}", expires_in: 30.minutes) do
      cache_hit = false
      @client.current_weather(lat: lat, lon: lon, units: @units)
    end

    forecast = Rails.cache.fetch("weather/forecast/#{lat}/#{lon}/#{@units}", expires_in: 30.minutes) do
      @client.forecast(lat: lat, lon: lon, units: @units)
    end

    { current: current, forecast: forecast, cache_hit: cache_hit }
  end
end
