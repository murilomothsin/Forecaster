class WeatherService
  def initialize(units: "metric")
    @units = units
    @client = OpenWeatherClient.new
  end

  def search_by_zip(zip_code, country_code = "US")
    geo = Rails.cache.fetch("weather/geo/#{zip_code}/#{country_code}", expires_in: 6.hours) do
      @client.geocode_zip(zip_code, country_code)
    end
    fetch_weather(geo["lat"], geo["lon"])
  end

  def search_by_city(city, country_code = "US")
    results = Rails.cache.fetch("weather/geo/#{city}/#{country_code}", expires_in: 6.hours) do
      @client.geocode_city(city, country_code)
    end
    raise OpenWeatherClient::ApiError.new("City not found", code: 404) if results.empty?

    geo = results.first
    fetch_weather(geo["lat"], geo["lon"])
  end

  private

  def fetch_weather(lat, lon)
    cache_hit = Rails.cache.exist?("weather/current/#{lat}/#{lon}/#{@units}") || Rails.cache.exist?("weather/forecast/#{lat}/#{lon}/#{@units}")

    current = Rails.cache.fetch("weather/current/#{lat}/#{lon}/#{@units}", expires_in: 30.minutes) do
      @client.current_weather(lat: lat, lon: lon, units: @units)
    end

    forecast = Rails.cache.fetch("weather/forecast/#{lat}/#{lon}/#{@units}", expires_in: 30.minutes) do
      @client.forecast(lat: lat, lon: lon, units: @units)
    end

    { current: current, forecast: forecast, cache_hit: cache_hit }
  end
end
