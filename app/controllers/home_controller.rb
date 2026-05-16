class HomeController < ApplicationController
  rate_limit to: 10, within: 1.minute, only: :index, if: :search_params?,
             with: -> {
               @error = "Too many requests. Please wait a moment before trying again."
               render :index, status: :too_many_requests
             }

  def index
    return unless search_params?

    @search = WeatherSearch.new(permitted_params.to_h)
    unless @search.valid?
      @error = @search.errors.full_messages.to_sentence
      return
    end

    result = search_weather
    @weather = WeatherPresenter.new(
      forecast: result[:current],
      extended_forecast: result[:forecast],
      cache_hit: result[:cache_hit]
    )
  rescue OpenWeatherClient::ApiError => e
    @error = e.message
  rescue StandardError => e
    Rails.logger.error("Weather search failed: #{e.class} - #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
    @error = "Something went wrong. Please try again later."
  end

  private

  def weather_service
    @weather_service ||= WeatherService.new(units: @search.units)
  end

  def permitted_params
    @permitted_params ||= params.permit(:search_mode, :zip_code, :city, :country, :units)
  end

  def search_params?
    params[:zip_code].present? || params[:city].present?
  end

  def search_weather
    if @search.city_search?
      weather_service.search_by_city(@search.city, @search.country)
    else
      weather_service.search_by_zip(@search.zip_code, @search.country)
    end
  end
end
