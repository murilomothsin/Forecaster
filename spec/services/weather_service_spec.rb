require "rails_helper"

RSpec.describe WeatherService do
  let(:client) { instance_double(OpenWeatherClient) }
  let(:geo_response) { { "lat" => 40.7484, "lon" => -73.9967, "name" => "New York" } }
  let(:city_geo_response) { [{ "lat" => 51.5074, "lon" => -0.1278, "name" => "London" }] }
  let(:current_response) do
    {
      "name" => "New York",
      "main" => { "temp" => 21.5, "feels_like" => 20.0, "humidity" => 55 },
      "weather" => [{ "description" => "clear sky", "icon" => "01d" }]
    }
  end
  let(:forecast_response) do
    {
      "list" => [
        { "dt" => 1779206400, "main" => { "temp" => 16.0 }, "weather" => [{ "icon" => "04n" }] }
      ]
    }
  end

  before do
    allow(OpenWeatherClient).to receive(:new).and_return(client)
    allow(client).to receive(:geocode_zip).and_return(geo_response)
    allow(client).to receive(:geocode_city).and_return(city_geo_response)
    allow(client).to receive(:current_weather).and_return(current_response)
    allow(client).to receive(:forecast).and_return(forecast_response)
  end

  describe "#initialize" do
    it "defaults to metric units" do
      weather = WeatherService.new
      expect(weather.instance_variable_get(:@units)).to eq("metric")
    end

    it "accepts custom units" do
      weather = WeatherService.new(units: "imperial")
      expect(weather.instance_variable_get(:@units)).to eq("imperial")
    end
  end

  describe "#search_by_zip" do
    it "geocodes the zip then fetches weather and forecast" do
      weather = WeatherService.new
      result = weather.search_by_zip("10001", "US")

      expect(client).to have_received(:geocode_zip).with("10001", "US")
      expect(client).to have_received(:current_weather).with(lat: 40.7484, lon: -73.9967, units: "metric")
      expect(client).to have_received(:forecast).with(lat: 40.7484, lon: -73.9967, units: "metric")
      expect(result[:current]).to eq(current_response)
      expect(result[:forecast]).to eq(forecast_response)
    end

    it "defaults country to US" do
      WeatherService.new.search_by_zip("10001")
      expect(client).to have_received(:geocode_zip).with("10001", "US")
    end

    it "returns cache_hit false on first call" do
      result = WeatherService.new.search_by_zip("10001")
      expect(result[:cache_hit]).to be false
    end

    it "passes custom units to the client" do
      WeatherService.new(units: "imperial").search_by_zip("10001")
      expect(client).to have_received(:current_weather).with(lat: 40.7484, lon: -73.9967, units: "imperial")
      expect(client).to have_received(:forecast).with(lat: 40.7484, lon: -73.9967, units: "imperial")
    end

    context "with cache" do
      before do
        allow(Rails.cache).to receive(:fetch) do |key, opts, &block|
          @cache ||= {}
          if @cache.key?(key)
            @cache[key]
          else
            @cache[key] = block.call
          end
        end
      end

      it "returns cache_hit true on subsequent calls" do
        weather = WeatherService.new
        weather.search_by_zip("10001")
        result = weather.search_by_zip("10001")
        expect(result[:cache_hit]).to be true
      end

      it "does not re-call client for cached data" do
        weather = WeatherService.new
        weather.search_by_zip("10001")
        weather.search_by_zip("10001")
        expect(client).to have_received(:current_weather).once
        expect(client).to have_received(:forecast).once
      end
    end
  end

  describe "#search_by_city" do
    it "geocodes the city then fetches weather and forecast" do
      weather = WeatherService.new
      result = weather.search_by_city("London", "GB")

      expect(client).to have_received(:geocode_city).with("London", "GB")
      expect(client).to have_received(:current_weather).with(lat: 51.5074, lon: -0.1278, units: "metric")
      expect(client).to have_received(:forecast).with(lat: 51.5074, lon: -0.1278, units: "metric")
      expect(result[:current]).to eq(current_response)
      expect(result[:forecast]).to eq(forecast_response)
    end

    it "works without country code" do
      WeatherService.new.search_by_city("London")
      expect(client).to have_received(:geocode_city).with("London", nil)
    end

    it "raises when no city is found" do
      allow(client).to receive(:geocode_city).and_return([])
      expect { WeatherService.new.search_by_city("Nonexistent") }
        .to raise_error(OpenWeatherClient::ApiError, "City not found")
    end
  end
end
