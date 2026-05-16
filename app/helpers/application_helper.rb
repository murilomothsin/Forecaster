module ApplicationHelper
  COUNTRY_OPTIONS = ISO3166::Country.pluck(:iso_short_name, :alpha2).sort_by(&:first).freeze

  UNIT_OPTIONS = [
    [ "Celsius (°C)", "metric" ],
    [ "Fahrenheit (°F)", "imperial" ],
    [ "Kelvin (K)", "standard" ]
  ].freeze

  def unit_label(units)
    case units
    when "imperial" then "°F"
    when "standard" then "K"
    else "°C"
    end
  end
end
