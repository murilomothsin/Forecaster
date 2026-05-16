class ForecastEntry
  def initialize(entry)
    @entry = entry
  end

  def time
    Time.at(@entry["dt"]).utc.strftime("%H:%M")
  end

  def icon_path
    WeatherIcon.path_for(@entry.dig("weather", 0, "icon"))
  end

  def condition
    @entry.dig("weather", 0, "description")
  end

  def temperature
    @entry.dig("main", "temp")&.round
  end

  def humidity
    @entry.dig("main", "humidity")
  end
end
