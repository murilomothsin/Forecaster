class WeatherPresenter
  attr_reader :daily_forecasts

  def initialize(forecast:, extended_forecast: nil, cache_hit: false)
    @forecast = forecast
    @cache_hit = cache_hit
    @daily_forecasts = build_daily_forecasts(extended_forecast)
  end

  def city_name
    @forecast.name
  end

  def icon_url
    @forecast.weather.first.icon_uri.to_s
  end

  def condition
    @forecast.weather.first.description
  end

  def temperature
    @forecast.main.temp.round
  end

  def feels_like
    @forecast.main.feels_like.round
  end

  def humidity
    @forecast.main.humidity
  end

  def cache_hit?
    @cache_hit
  end

  def cache_label
    @cache_hit ? "Cached" : "Live"
  end

  def cache_css_classes
    @cache_hit ? "bg-yellow-100 text-yellow-800" : "bg-green-100 text-green-800"
  end

  def extended_forecast?
    @daily_forecasts.any?
  end

  private

  def build_daily_forecasts(extended_forecast)
    return [] unless extended_forecast

    extended_forecast["list"]
      .group_by { |entry| entry["dt"].to_date }
      .map { |date, entries| DayForecast.new(date, entries) }
  end
end
