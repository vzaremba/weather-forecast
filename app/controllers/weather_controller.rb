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

      if @forecast
        @current_temperature = @forecast['list'][0]['main']['temp']
        @high_low_temps = high_low_temps_today(@forecast)
        @five_day_forecast = five_day_forecast(@forecast)
      else
        @error = "Error fetching weather for coordinates: #{coordinates}" unless @forecast
      end
    end
  rescue => e
    Rails.logger.error "Error in show action: #{e.message}"
    @error = "There was an error processing your request. Please try again."
    render 'show'
  end

  private

  def high_low_temps_today(forecast)
    today_forecasts = forecast['list'].first(8) # Gets forecasts for next 24 hours
    temperatures = today_forecasts.map { |f| f['main']['temp'] }
    { high: temperatures.max, low: temperatures.min }
  end

  def five_day_forecast(forecast)
    # Assuming the first forecast in the list starts at midnight and each subsequent forecast is for every 3 hours
    midday_forecasts = forecast['list'].each_slice(8).map { |s| s[4] }.first(5)
    midday_forecasts.map { |f| { date: f['dt_txt'], temp: f['main']['temp'], description: f['weather'].first['description'] } }
  end
end
