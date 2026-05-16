require "rails_helper"

RSpec.describe OpenWeatherClient do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key: api_key) }

  def stub_api(response_body, status: "200")
    response = instance_double(
      Net::HTTPResponse,
      body: response_body.to_json,
      code: status
    )
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(status == "200")
    allow(Net::HTTP).to receive(:get_response).and_return(response)
  end

  def expect_request_to(path, **expected_params)
    expect(Net::HTTP).to have_received(:get_response) do |uri|
      expect(uri.host).to eq("api.openweathermap.org")
      expect(uri.path).to eq(path)
      params = URI.decode_www_form(uri.query).to_h
      expect(params["appid"]).to eq(api_key)
      expected_params.each do |key, value|
        expect(params[key.to_s]).to eq(value.to_s)
      end
    end
  end

  describe "#geocode_zip" do
    let(:response) { { "zip" => "10001", "name" => "New York", "lat" => 40.7484, "lon" => -73.9967, "country" => "US" } }

    it "returns location data for a zip code" do
      stub_api(response)

      result = client.geocode_zip("10001", "US")

      expect(result).to eq(response)
      expect_request_to("/geo/1.0/zip", zip: "10001,US")
    end

    it "defaults country to US" do
      stub_api(response)

      client.geocode_zip("10001")

      expect_request_to("/geo/1.0/zip", zip: "10001,US")
    end
  end

  describe "#geocode_city" do
    let(:response) { [{ "name" => "London", "lat" => 51.5074, "lon" => -0.1278, "country" => "GB" }] }

    it "returns matching locations" do
      stub_api(response)

      result = client.geocode_city("London", "GB")

      expect(result).to eq(response)
      expect_request_to("/geo/1.0/direct", q: "London,GB", limit: "5")
    end

    it "works without country code" do
      stub_api(response)

      client.geocode_city("London")

      expect_request_to("/geo/1.0/direct", q: "London", limit: "5")
    end

    it "accepts custom limit" do
      stub_api(response)

      client.geocode_city("London", nil, limit: 1)

      expect_request_to("/geo/1.0/direct", q: "London", limit: "1")
    end
  end

  describe "#current_weather" do
    let(:response) do
      {
        "name" => "New York",
        "main" => { "temp" => 21.5, "feels_like" => 20.0, "humidity" => 55 },
        "weather" => [{ "description" => "clear sky", "icon" => "01d" }]
      }
    end

    it "returns weather data for coordinates" do
      stub_api(response)

      result = client.current_weather(lat: 40.7484, lon: -73.9967)

      expect(result).to eq(response)
      expect_request_to("/data/2.5/weather", lat: 40.7484, lon: -73.9967, units: "metric")
    end

    it "accepts custom units" do
      stub_api(response)

      client.current_weather(lat: 40.7484, lon: -73.9967, units: "imperial")

      expect_request_to("/data/2.5/weather", units: "imperial")
    end
  end

  describe "#forecast" do
    let(:response) do
      {
        "list" => [
          { "dt" => 1779206400, "main" => { "temp" => 16.0 }, "weather" => [{ "icon" => "04n" }] }
        ]
      }
    end

    it "returns forecast data for coordinates" do
      stub_api(response)

      result = client.forecast(lat: 40.7484, lon: -73.9967)

      expect(result).to eq(response)
      expect_request_to("/data/2.5/forecast", lat: 40.7484, lon: -73.9967, units: "metric")
    end
  end

  describe "error handling" do
    it "raises ApiError on non-success response" do
      stub_api({ "cod" => 401, "message" => "Invalid API key" }, status: "401")

      expect { client.current_weather(lat: 0, lon: 0) }
        .to raise_error(OpenWeatherClient::ApiError, "Invalid API key")
    end

    it "includes HTTP status code in the error" do
      stub_api({ "cod" => 404, "message" => "city not found" }, status: "404")

      expect { client.geocode_zip("00000") }
        .to raise_error(OpenWeatherClient::ApiError) { |e| expect(e.code).to eq(404) }
    end

    it "handles missing message in error response" do
      stub_api({ "cod" => 500 }, status: "500")

      expect { client.current_weather(lat: 0, lon: 0) }
        .to raise_error(OpenWeatherClient::ApiError, /Request failed/)
    end
  end
end
