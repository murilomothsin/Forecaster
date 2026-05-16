module ApplicationHelper
  COUNTRY_OPTIONS = ISO3166::Country.pluck(:iso_short_name, :alpha2).sort_by(&:first).freeze
end
