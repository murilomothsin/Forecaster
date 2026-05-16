class ForecastEntry
  def initialize(entry)
    @entry = entry
  end

  def time
    @entry["dt"].strftime("%H:%M")
  end

  def icon_url
    @entry["weather"].first["icon_uri"].to_s
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
