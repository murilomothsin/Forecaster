require 'rails_helper'

RSpec.describe Weather do
  describe '#initialize' do
    it 'sets units to metric by default' do
      weather = Weather.new
      expect(weather.instance_variable_get(:@options)[:units]).to eq('metric')
    end

    it 'accepts custom units' do
      weather = Weather.new(units: 'imperial')
      expect(weather.instance_variable_get(:@options)[:units]).to eq('imperial')
    end

    it 'initializes an OpenWeather client' do
      expect(OpenWeather::Client).to receive(:new)
      Weather.new
    end
  end

  describe '#current_weather' do
    let(:zip_code) { '12345' }
    let(:mock_client) { instance_double(OpenWeather::Client) }
    let(:weather_data) { { 'main' => { 'temp' => 20 }, 'weather' => [ { 'description' => 'sunny' } ] } }

    before do
      allow(OpenWeather::Client).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:current_zip).and_return(weather_data)
    end

    it 'returns a tuple with cache_hit and weather data' do
      weather = Weather.new
      cache_hit, data = weather.current_weather(zip_code)

      expect(data).to eq(weather_data)
      expect(cache_hit).to be_a(TrueClass).or be_a(FalseClass)
    end

    it 'returns cache_hit false on first call' do
      weather = Weather.new
      cache_hit, data = weather.current_weather(zip_code)

      expect(cache_hit).to be false
      expect(data).to eq(weather_data)
    end

    it 'calls the client with correct parameters' do
      weather = Weather.new
      expect(mock_client).to receive(:current_zip).with(zip_code, 'US', { units: 'metric' }).and_return(weather_data)

      weather.current_weather(zip_code)
    end

    it 'uses correct cache key format' do
      weather = Weather.new
      cache_key = "weather/#{zip_code}/unit/metric"

      expect(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 30.minutes).and_call_original

      weather.current_weather(zip_code)
    end

    it 'respects custom units in cache key' do
      weather = Weather.new(units: 'imperial')
      cache_key = "weather/#{zip_code}/unit/imperial"

      expect(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 30.minutes).and_call_original

      weather.current_weather(zip_code)
    end

    context 'with cache enabled' do
      before do
        allow(Rails.cache).to receive(:fetch) do |key, options, &block|
          @test_cache ||= {}
          if @test_cache.key?(key)
            @test_cache[key]
          else
            @test_cache[key] = block.call
          end
        end
      end

      it 'returns cache_hit false on first call' do
        weather = Weather.new
        cache_hit, _ = weather.current_weather(zip_code)
        expect(cache_hit).to be false
      end

      it 'returns cache_hit true on subsequent calls' do
        weather = Weather.new
        weather.current_weather(zip_code)
        cache_hit, _ = weather.current_weather(zip_code)

        expect(cache_hit).to be true
      end

      it 'calls the client only on first request' do
        weather = Weather.new
        expect(mock_client).to receive(:current_zip).once.with(zip_code, 'US', { units: 'metric' }).and_return(weather_data)

        weather.current_weather(zip_code)
        weather.current_weather(zip_code)
      end

      it 'returns different cache statuses for different zip codes' do
        weather = Weather.new

        cache_hit1, _ = weather.current_weather('12345')
        cache_hit2, _ = weather.current_weather('67890')
        cache_hit3, _ = weather.current_weather('12345')

        expect(cache_hit1).to be false
        expect(cache_hit2).to be false
        expect(cache_hit3).to be true
      end
    end
  end

  describe '#complete_weather' do
    let(:latitude) { 40.7128 }
    let(:longitude) { -74.0060 }
    let(:mock_client) { instance_double(OpenWeather::Client) }
    let(:forecast_data) do
      {
        'list' => [
          { 'main' => { 'temp' => 15 }, 'weather' => [ { 'description' => 'cloudy' } ] },
          { 'main' => { 'temp' => 18 }, 'weather' => [ { 'description' => 'sunny' } ] }
        ]
      }
    end

    before do
      allow(OpenWeather::Client).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:five_day_forecast).and_return(forecast_data)
    end

    it 'returns forecast data for given latitude and longitude' do
      weather = Weather.new
      data = weather.complete_weather(latitude, longitude)

      expect(data).to eq(forecast_data)
    end

    it 'calls the client with correct parameters' do
      weather = Weather.new
      expect(mock_client).to receive(:five_day_forecast).with(lat: latitude, lon: longitude, units: 'metric').and_return(forecast_data)

      weather.complete_weather(latitude, longitude)
    end

    it 'uses correct cache key format' do
      weather = Weather.new
      cache_key = "weather/lat/#{latitude}/lon/#{longitude}/unit/metric"

      expect(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 30.minutes).and_call_original

      weather.complete_weather(latitude, longitude)
    end

    it 'respects custom units in cache key' do
      weather = Weather.new(units: 'imperial')
      cache_key = "weather/lat/#{latitude}/lon/#{longitude}/unit/imperial"

      expect(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 30.minutes).and_call_original

      weather.complete_weather(latitude, longitude)
    end

    it 'passes custom units to the client' do
      weather = Weather.new(units: 'imperial')
      expect(mock_client).to receive(:five_day_forecast).with(lat: latitude, lon: longitude, units: 'imperial').and_return(forecast_data)

      weather.complete_weather(latitude, longitude)
    end

    context 'with cache enabled' do
      before do
        allow(Rails.cache).to receive(:fetch) do |key, options, &block|
          @test_cache ||= {}
          if @test_cache.key?(key)
            @test_cache[key]
          else
            @test_cache[key] = block.call
          end
        end
      end

      it 'caches the result' do
        weather = Weather.new
        expect(mock_client).to receive(:five_day_forecast).once.with(lat: latitude, lon: longitude, units: 'metric').and_return(forecast_data)

        weather.complete_weather(latitude, longitude)
        weather.complete_weather(latitude, longitude)
      end

      it 'uses different cache keys for different coordinates' do
        weather = Weather.new
        expect(mock_client).to receive(:five_day_forecast).twice.and_return(forecast_data)

        weather.complete_weather(40.7128, -74.0060)
        weather.complete_weather(34.0522, -118.2437)
      end
    end
  end
end
