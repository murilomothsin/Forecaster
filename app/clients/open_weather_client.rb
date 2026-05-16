require "net/http"
require "json"

class OpenWeatherClient
  BASE_URI = "https://api.openweathermap.org"

  class ApiError < StandardError
    attr_reader :code

    def initialize(message, code: nil)
      @code = code
      super(message)
    end
  end

  def initialize(api_key: Rails.application.credentials.dig(:open_weather, :api_key))
    raise ApiError, "OpenWeather API key is not configured. Run: bin/rails credentials:edit" if api_key.blank?

    @api_key = api_key
  end

  def geocode_zip(zip, country_code = "US")
    get("/geo/1.0/zip", zip: "#{zip},#{country_code}")
  end

  def geocode_city(city, country_code = nil, limit: 5)
    query = [ city, country_code ].compact.join(",")
    get("/geo/1.0/direct", q: query, limit: limit)
  end

  def current_weather(lat:, lon:, units: "metric")
    get("/data/2.5/weather", lat: lat, lon: lon, units: units)
  end

  def forecast(lat:, lon:, units: "metric")
    get("/data/2.5/forecast", lat: lat, lon: lon, units: units)
  end

  private

  def get(path, params = {})
    uri = URI("#{BASE_URI}#{path}")
    uri.query = URI.encode_www_form(params.merge(appid: @api_key))

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 5
    http.read_timeout = 5

    response = http.request(Net::HTTP::Get.new(uri))
    body = JSON.parse(response.body)

    unless response.is_a?(Net::HTTPSuccess)
      raise ApiError.new(body["message"] || "Request failed (#{response.code})", code: response.code.to_i)
    end

    body
  end
end
