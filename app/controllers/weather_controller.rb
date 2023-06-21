class WeatherController < ApplicationController
  def index
  end

  def show
    address = params[:address]
    coordinates = Geocoder.coordinates(address)
    @forecast = get_forecast(coordinates)
    @location = Geocoder.search(address).first
  end

  private

  def get_forecast(coordinates)
    cache_key = "forecast_#{coordinates.join('_')}"
    @from_cache = Rails.cache.exist?(cache_key)
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      url = 'http://api.openweathermap.org/data/2.5/weather'
      params = { lat: coordinates[0], lon: coordinates[1], APPID: ENV['OPENWEATHER_API_KEY'], units: 'imperial' }
      response = Faraday.get(url, params)
      JSON.parse(response.body)
    end
  end
end
