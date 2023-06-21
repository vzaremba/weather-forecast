class WeatherController < ApplicationController
  def index
  end

  def show
    address = params[:address]
    @location = GeocodingService.search(address)

    if @location
      coordinates = [@location.data['lat'], @location.data['lon']]
      cache_key = "forecast_#{coordinates.join('_')}"
      @from_cache = Rails.cache.exist?(cache_key)

      begin
        forecast_data = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
          WeatherService.new.forecast(*coordinates)
        end

        @forecast = Forecast.new(forecast_data)
      rescue => e
        Rails.logger.error "Error fetching weather for coordinates: #{coordinates}. Error: #{e.message}"
        @error = "Error fetching weather for coordinates: #{coordinates}"
      end
    else
      @error = "Error geocoding address: #{address}"
    end

    if @error
      Rails.logger.error @error
      render 'show'
    end
  rescue => e
    Rails.logger.error "Error in show action: #{e.message}"
    @error = "There was an error processing your request. Please try again."
    render 'show'
  end
end
