require "rails_helper"

RSpec.describe WeatherSearch do
  describe "defaults" do
    it "defaults search_mode to zip" do
      search = described_class.new
      expect(search.search_mode).to eq("zip")
    end

    it "defaults country to US" do
      search = described_class.new
      expect(search.country).to eq("US")
    end
  end

  describe "#city_search?" do
    it "returns true when search_mode is city" do
      search = described_class.new(search_mode: "city")
      expect(search.city_search?).to be true
    end

    it "returns false when search_mode is zip" do
      search = described_class.new(search_mode: "zip")
      expect(search.city_search?).to be false
    end
  end

  describe "#zip_search?" do
    it "returns true when search_mode is zip" do
      search = described_class.new(search_mode: "zip")
      expect(search.zip_search?).to be true
    end

    it "returns false when search_mode is city" do
      search = described_class.new(search_mode: "city")
      expect(search.zip_search?).to be false
    end
  end

  describe "zip code validations" do
    it "is valid with a proper zip code" do
      search = described_class.new(zip_code: "10001")
      expect(search).to be_valid
    end

    it "is invalid without a zip code" do
      search = described_class.new(zip_code: "")
      expect(search).not_to be_valid
      expect(search.errors[:zip_code]).to include("can't be blank")
    end

    it "is invalid with a zip code longer than 10 characters" do
      search = described_class.new(zip_code: "12345678901")
      expect(search).not_to be_valid
      expect(search.errors[:zip_code]).to include("is invalid")
    end

    it "accepts alphanumeric zip codes with spaces and hyphens" do
      expect(described_class.new(zip_code: "SW1A 1AA")).to be_valid
      expect(described_class.new(zip_code: "H0H-0H0")).to be_valid
    end

    it "rejects zip codes with special characters" do
      search = described_class.new(zip_code: "100<>01")
      expect(search).not_to be_valid
    end

    it "does not validate zip_code when search_mode is city" do
      search = described_class.new(search_mode: "city", city: "London")
      expect(search).to be_valid
    end
  end

  describe "city validations" do
    it "is valid with a city name" do
      search = described_class.new(search_mode: "city", city: "London")
      expect(search).to be_valid
    end

    it "is invalid without a city name" do
      search = described_class.new(search_mode: "city", city: "")
      expect(search).not_to be_valid
      expect(search.errors[:city]).to include("can't be blank")
    end

    it "is invalid with a city name longer than 100 characters" do
      search = described_class.new(search_mode: "city", city: "A" * 101)
      expect(search).not_to be_valid
      expect(search.errors[:city]).to include("is too long (maximum is 100 characters)")
    end

    it "does not validate city when search_mode is zip" do
      search = described_class.new(search_mode: "zip", zip_code: "10001")
      expect(search).to be_valid
    end
  end

  describe "country validation" do
    it "is valid with a real ISO alpha2 code" do
      search = described_class.new(zip_code: "10001", country: "BR")
      expect(search).to be_valid
    end

    it "is invalid with a fake country code" do
      search = described_class.new(zip_code: "10001", country: "ZZ")
      expect(search).not_to be_valid
      expect(search.errors[:country]).to include("is not a valid country code")
    end

    it "skips validation when country is blank" do
      search = described_class.new(zip_code: "10001", country: "")
      expect(search).to be_valid
    end
  end
end
