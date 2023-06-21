class WeatherService
  def initialize(coordinates)
    @lat = coordinates[0]
    @lon = coordinates[1]
  end

  def forecast
    url = 'http://api.openweathermap.org/data/2.5/weather'
    params = { lat: @lat, lon: @lon, APPID: ENV['OPENWEATHER_API_KEY'], units: 'imperial' }
    response = Faraday.get(url, params)

    JSON.parse(response.body)
  end
end
