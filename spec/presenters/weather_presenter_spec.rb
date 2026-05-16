require "rails_helper"

RSpec.describe WeatherPresenter do
  let(:forecast) do
    {
      "name" => "New York",
      "weather" => [ { "icon" => "01d", "description" => "clear sky" } ],
      "main" => { "temp" => 21.84, "feels_like" => 20.52, "humidity" => 55 }
    }
  end

  let(:extended_forecast) do
    {
      "list" => [
        build_entry(Time.utc(2026, 5, 16, 9, 0).to_i, 16.32, 87, "overcast clouds", "04n"),
        build_entry(Time.utc(2026, 5, 16, 12, 0).to_i, 16.19, 84, "broken clouds", "04n"),
        build_entry(Time.utc(2026, 5, 17, 9, 0).to_i, 18.41, 81, "scattered clouds", "04d"),
        build_entry(Time.utc(2026, 5, 17, 12, 0).to_i, 20.65, 69, "scattered clouds", "04d")
      ]
    }
  end

  def build_entry(dt, temp, humidity, description, icon)
    {
      "dt" => dt,
      "main" => { "temp" => temp, "humidity" => humidity },
      "weather" => [ { "icon" => icon, "description" => description } ]
    }
  end

  describe "current weather" do
    subject { described_class.new(forecast: forecast, cache_hit: false) }

    it "returns city name" do
      expect(subject.city_name).to eq("New York")
    end

    it "returns icon URL" do
      expect(subject.icon_url).to eq("https://openweathermap.org/img/wn/01d@2x.png")
    end

    it "returns condition description" do
      expect(subject.condition).to eq("clear sky")
    end

    it "returns rounded temperature" do
      expect(subject.temperature).to eq(22)
    end

    it "returns rounded feels_like" do
      expect(subject.feels_like).to eq(21)
    end

    it "returns humidity" do
      expect(subject.humidity).to eq(55)
    end
  end

  describe "cache status" do
    it "returns Live label when not cached" do
      presenter = described_class.new(forecast: forecast, cache_hit: false)

      expect(presenter.cache_hit?).to be false
      expect(presenter.cache_label).to eq("Live")
      expect(presenter.cache_css_classes).to eq("bg-green-100 text-green-800")
    end

    it "returns Cached label when cached" do
      presenter = described_class.new(forecast: forecast, cache_hit: true)

      expect(presenter.cache_hit?).to be true
      expect(presenter.cache_label).to eq("Cached")
      expect(presenter.cache_css_classes).to eq("bg-yellow-100 text-yellow-800")
    end
  end

  describe "extended forecast" do
    it "reports no extended forecast when nil" do
      presenter = described_class.new(forecast: forecast)

      expect(presenter.extended_forecast?).to be false
      expect(presenter.daily_forecasts).to eq([])
    end

    it "reports extended forecast when present" do
      presenter = described_class.new(forecast: forecast, extended_forecast: extended_forecast)

      expect(presenter.extended_forecast?).to be true
    end

    it "groups entries by day" do
      presenter = described_class.new(forecast: forecast, extended_forecast: extended_forecast)

      expect(presenter.daily_forecasts.size).to eq(2)
    end

    it "creates DayForecast objects in chronological order" do
      presenter = described_class.new(forecast: forecast, extended_forecast: extended_forecast)

      dates = presenter.daily_forecasts.map(&:formatted_date)
      expect(dates).to eq([ "Saturday, May 16", "Sunday, May 17" ])
    end

    it "assigns correct entries per day" do
      presenter = described_class.new(forecast: forecast, extended_forecast: extended_forecast)

      expect(presenter.daily_forecasts[0].entries.size).to eq(2)
      expect(presenter.daily_forecasts[1].entries.size).to eq(2)
    end
  end
end
