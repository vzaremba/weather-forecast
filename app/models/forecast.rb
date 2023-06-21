class Forecast
  attr_reader :data

  FORECAST_INTERVALS_PER_DAY = 8

  def initialize(data)
    @data = data
  end

  def current_temperature
    data['list'][0]['main']['temp']
  end

  def high_temperature
    today_forecasts = data['list'].first(FORECAST_INTERVALS_PER_DAY) # Gets forecasts for next 24 hours
    temperatures = today_forecasts.map { |f| f['main']['temp'] }
    @high_temperature ||= temperatures.max
  end

  def low_temperature
    today_forecasts = data['list'].first(FORECAST_INTERVALS_PER_DAY) # Gets forecasts for next 24 hours
    temperatures = today_forecasts.map { |f| f['main']['temp'] }
    @low_temperature ||= temperatures.min
  end

  def five_day_forecast
    # Assuming the first forecast in the list starts at midnight and each subsequent forecast is for every 3 hours
    midday_forecasts = data['list'].each_slice(FORECAST_INTERVALS_PER_DAY).map { |s| s[4] }.compact.first(5)
    @five_day_forecast ||= midday_forecasts.map do |f|
      {
        date: f['dt_txt'],
        temp: f['main']['temp'],
        description: f['weather'].first['description']
      }
    end
  end
end
