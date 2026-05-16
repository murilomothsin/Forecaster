class ForecastEntry
  ICON_BASE_URL = "https://openweathermap.org/img/wn"

  def initialize(entry)
    @entry = entry
  end

  def time
    Time.at(@entry["dt"]).utc.strftime("%H:%M")
  end

  def icon_url
    "#{ICON_BASE_URL}/#{@entry["weather"].first["icon"]}@2x.png"
  end

  def condition
    @entry["weather"].first["description"]
  end

  def temperature
    @entry["main"]["temp"].round
  end

  def humidity
    @entry["main"]["humidity"]
  end
end
