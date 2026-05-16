class HomeController < ApplicationController
  before_action :weather
  def index
    return unless params[:zip_code].present?

    @cache_hit, @forecast = @weather_service.current_weather(params[:zip_code])

    @extended_forecast = @weather_service.complete_weather(@forecast['coord']['lat'], @forecast['coord']['lon']) if @forecast
  rescue StandardError => e
    @error = e.message
  end

  private
  def weather
    @weather_service ||= Weather.new
  end
end
