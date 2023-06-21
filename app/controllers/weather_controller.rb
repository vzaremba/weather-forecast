class WeatherController < ApplicationController
  def index
  end

  def show
    address = params[:address]
    @location = Geocoder.search(address).first
    @error = "Error geocoding address: #{address}" unless @location

    if @location
      coordinates = [@location.data['lat'], @location.data['lon']]
      cache_key = "forecast_#{coordinates.join('_')}"
      @from_cache = Rails.cache.exist?(cache_key)

      @forecast = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
        WeatherService.new(coordinates).forecast
      end

      @error = "Error fetching weather for coordinates: #{coordinates}" unless @forecast
    end
  rescue => e
    Rails.logger.error "Error in show action: #{e.message}"
    @error = "There was an error processing your request. Please try again."
    render 'show'
  end
end
