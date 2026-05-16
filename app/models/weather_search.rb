class WeatherSearch
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :search_mode, :string, default: "zip"
  attribute :zip_code, :string
  attribute :city, :string
  attribute :country, :string, default: "US"

  validates :city, presence: true, length: { maximum: 100 }, if: :city_search?
  validates :zip_code, presence: true, format: { with: /\A[\w\s\-]{2,10}\z/ }, if: :zip_search?
  validate :country_must_be_valid, if: -> { country.present? }

  def city_search?
    search_mode == "city"
  end

  def zip_search?
    !city_search?
  end

  private

  def country_must_be_valid
    errors.add(:country, "is not a valid country code") unless ISO3166::Country.codes.include?(country)
  end
end
