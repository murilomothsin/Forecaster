class WeatherIcon
  MAPPING = {
    "01d" => "clear-day",
    "01n" => "clear-night",
    "02d" => "mostly-clear-day",
    "02n" => "mostly-clear-night",
    "03d" => "partly-cloudy-day",
    "03n" => "partly-cloudy-night",
    "04d" => "overcast-day",
    "04n" => "overcast-night",
    "09d" => "drizzle",
    "09n" => "drizzle",
    "10d" => "partly-cloudy-day-rain",
    "10n" => "partly-cloudy-night-rain",
    "11d" => "thunderstorms-day",
    "11n" => "thunderstorms-night",
    "13d" => "partly-cloudy-day-snow",
    "13n" => "partly-cloudy-night-snow",
    "50d" => "mist",
    "50n" => "mist"
  }.freeze

  FALLBACK = "not-available"

  def self.path_for(code)
    name = MAPPING.fetch(code, FALLBACK)
    "meteocons/#{name}.svg"
  end
end
