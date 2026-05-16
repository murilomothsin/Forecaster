class HomeController < ApplicationController
  def index
    return unless search_params?

    result = search_weather
    @weather = WeatherPresenter.new(
      forecast: result[:current],
      extended_forecast: result[:forecast],
      cache_hit: result[:cache_hit]
    )
  rescue StandardError => e
    @error = e.message
  end

  private

  def weather_service
    @weather_service ||= WeatherService.new
  end

  def search_params?
    params[:zip_code].present? || params[:city].present?
  end

  def search_weather
    if params[:search_mode] == "city"
      weather_service.search_by_city(params[:city], params[:country].presence)
    else
      weather_service.search_by_zip(params[:zip_code], params[:country] || "US")
    end
  end
end
