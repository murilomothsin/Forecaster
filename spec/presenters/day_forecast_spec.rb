require "rails_helper"

RSpec.describe DayForecast do
  let(:entries) do
    [
      {
        "dt" => Time.utc(2026, 5, 17, 9, 0),
        "main" => { "temp" => 16.86, "humidity" => 72 },
        "weather" => [{ "icon_uri" => URI("http://openweathermap.org/img/wn/04n@2x.png"), "description" => "broken clouds" }]
      },
      {
        "dt" => Time.utc(2026, 5, 17, 12, 0),
        "main" => { "temp" => 16.26, "humidity" => 73 },
        "weather" => [{ "icon_uri" => URI("http://openweathermap.org/img/wn/04n@2x.png"), "description" => "broken clouds" }]
      }
    ]
  end

  subject { described_class.new(Date.new(2026, 5, 17), entries) }

  it "formats the date with day of week" do
    expect(subject.formatted_date).to eq("Sunday, May 17")
  end

  it "wraps raw entries into ForecastEntry objects" do
    expect(subject.entries.size).to eq(2)
    expect(subject.entries).to all(be_a(ForecastEntry))
  end
end
