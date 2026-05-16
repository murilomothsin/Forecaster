require "rails_helper"

RSpec.describe "Home", type: :request do
  let(:client) { instance_double(OpenWeatherClient) }
  let(:geo_zip_response) { { "lat" => 40.7484, "lon" => -73.9967, "name" => "New York" } }
  let(:geo_city_response) { [{ "lat" => 51.5074, "lon" => -0.1278, "name" => "London" }] }
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
        {
          "dt" => Time.utc(2026, 5, 16, 9, 0).to_i,
          "main" => { "temp" => 16.0, "humidity" => 80 },
          "weather" => [{ "icon" => "04n", "description" => "overcast clouds" }]
        }
      ]
    }
  end

  before do
    allow(OpenWeatherClient).to receive(:new).and_return(client)
    allow(client).to receive(:geocode_zip).and_return(geo_zip_response)
    allow(client).to receive(:geocode_city).and_return(geo_city_response)
    allow(client).to receive(:current_weather).and_return(current_response)
    allow(client).to receive(:forecast).and_return(forecast_response)
  end

  it "renders the search form without results" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Weather Forecast")
    expect(response.body).not_to include("Temperature")
  end

  it "searches by zip code and country" do
    get root_path, params: { zip_code: "10001", country: "US" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("New York")
    expect(client).to have_received(:geocode_zip).with("10001", "US")
  end

  it "searches by city and country" do
    get root_path, params: { city: "London", country: "GB", search_mode: "city" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("New York")
    expect(client).to have_received(:geocode_city).with("London", "GB")
  end

  it "shows error when API fails" do
    allow(client).to receive(:geocode_zip)
      .and_raise(OpenWeatherClient::ApiError.new("city not found", code: 404))

    get root_path, params: { zip_code: "00000", country: "US" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("city not found")
  end

  it "uses search_mode to dispatch even when both fields are present" do
    get root_path, params: { zip_code: "10001", city: "London", country: "GB", search_mode: "city" }

    expect(client).to have_received(:geocode_city).with("London", "GB")
    expect(client).not_to have_received(:geocode_zip)
  end
end
