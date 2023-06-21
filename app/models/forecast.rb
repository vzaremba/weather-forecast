class Forecast
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def current_temperature
    data['list'][0]['main']['temp']
  end

  def high_temperature
    today_forecasts = data['list'].first(8) # Gets forecasts for next 24 hours
    temperatures = today_forecasts.map { |f| f['main']['temp'] }
    temperatures.max
  end

  def low_temperature
    today_forecasts = data['list'].first(8) # Gets forecasts for next 24 hours
    temperatures = today_forecasts.map { |f| f['main']['temp'] }
    temperatures.min
  end

  def five_day_forecast
    # Assuming the first forecast in the list starts at midnight and each subsequent forecast is for every 3 hours
    midday_forecasts = data['list'].each_slice(8).map { |s| s[4] }.first(5)
    midday_forecasts.map { |f| { date: f['dt_txt'], temp: f['main']['temp'], description: f['weather'].first['description'] } }
  end
end
