require "rails_helper"

RSpec.describe ForecastEntry do
  let(:entry) do
    {
      "dt" => Time.utc(2026, 5, 16, 18, 0),
      "main" => { "temp" => 19.4, "humidity" => 54 },
      "weather" => [
        {
          "icon_uri" => URI("http://openweathermap.org/img/wn/02d@2x.png"),
          "description" => "few clouds"
        }
      ]
    }
  end

  subject { described_class.new(entry) }

  it "formats time as HH:MM" do
    expect(subject.time).to eq("18:00")
  end

  it "returns icon URL as string" do
    expect(subject.icon_url).to eq("http://openweathermap.org/img/wn/02d@2x.png")
  end

  it "returns condition description" do
    expect(subject.condition).to eq("few clouds")
  end

  it "returns rounded temperature" do
    expect(subject.temperature).to eq(19)
  end

  it "returns humidity" do
    expect(subject.humidity).to eq(54)
  end
end
