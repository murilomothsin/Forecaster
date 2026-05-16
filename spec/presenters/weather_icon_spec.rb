require "rails_helper"

RSpec.describe WeatherIcon do
  describe ".path_for" do
    it "maps clear day icon" do
      expect(described_class.path_for("01d")).to eq("meteocons/clear-day.svg")
    end

    it "maps clear night icon" do
      expect(described_class.path_for("01n")).to eq("meteocons/clear-night.svg")
    end

    it "maps thunderstorm day icon" do
      expect(described_class.path_for("11d")).to eq("meteocons/thunderstorms-day.svg")
    end

    it "maps mist icon" do
      expect(described_class.path_for("50d")).to eq("meteocons/mist.svg")
    end

    it "returns fallback for unknown codes" do
      expect(described_class.path_for("99x")).to eq("meteocons/not-available.svg")
    end

    it "returns fallback for nil" do
      expect(described_class.path_for(nil)).to eq("meteocons/not-available.svg")
    end
  end
end
