class WeatherController < ApplicationController
  def index
  end

  def show
    address = params[:address]
    @location = Geocoder.search(address).first

    coordinates = [@location.data['lat'], @location.data['lon']]
    cache_key = "forecast_#{coordinates.join('_')}"

    @from_cache = Rails.cache.exist?(cache_key)
    @forecast = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      WeatherService.new(coordinates).forecast
    end
  end
end
