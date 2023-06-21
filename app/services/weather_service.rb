class WeatherService
  def initialize(coordinates)
    @lat = coordinates[0]
    @lon = coordinates[1]
  end

  def forecast
    url = 'http://api.openweathermap.org/data/2.5/forecast'
    params = {
      lat: @lat,
      lon: @lon,
      APPID: ENV['OPENWEATHER_API_KEY'], units: 'imperial'
    }
    response = Faraday.get(url, params)
    raise "Error fetching weather: #{response.status}" unless response.success?

    JSON.parse(response.body)
  rescue Faraday::Error => e
    Rails.logger.error "Faraday error: #{e.message}"
    nil
  end
end
