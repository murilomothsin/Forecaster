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
    let(:weather) { Weather.new }
    let(:zip_code) { '12345' }
    let(:mock_client) { instance_double(OpenWeather::Client) }
    let(:weather_data) { { 'main' => { 'temp' => 20 }, 'weather' => [{ 'description' => 'sunny' }] } }

    before do
      allow(OpenWeather::Client).to receive(:new).and_return(mock_client)
      @weather = Weather.new
    end

    it 'returns weather data for a zip code' do
      allow(mock_client).to receive(:current_zip).with(zip_code, 'US', { units: 'metric' }).and_return(weather_data)

      result = @weather.current_weather(zip_code)
      expect(result).to eq(weather_data)
    end

    it 'calls the client with correct parameters' do
      expect(mock_client).to receive(:current_zip).with(zip_code, 'US', { units: 'metric' }).and_return(weather_data)

      @weather.current_weather(zip_code)
    end

    it 'caches the result' do
      allow(mock_client).to receive(:current_zip).with(zip_code, 'US', { units: 'metric' }).and_return(weather_data)
      
      # Verify that fetch is called with correct cache key and expiration
      expect(Rails.cache).to receive(:fetch).with("weather/#{zip_code}/unit/metric", expires_in: 30.minutes).and_call_original
      
      @weather.current_weather(zip_code)
    end

    it 'uses correct cache key format' do
      cache_key = "weather/#{zip_code}/unit/metric"
      expect(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 30.minutes)

      @weather.current_weather(zip_code)
    end

    it 'respects custom units in cache key' do
      weather_with_imperial = Weather.new(units: 'imperial')
      allow(OpenWeather::Client).to receive(:new).and_return(mock_client)

      cache_key = "weather/#{zip_code}/unit/imperial"
      expect(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 30.minutes)

      weather_with_imperial.current_weather(zip_code)
    end
  end
end
