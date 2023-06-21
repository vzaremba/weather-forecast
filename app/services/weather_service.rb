class WeatherService
  URL = 'http://api.openweathermap.org/data/2.5/forecast'
  UNITS = 'imperial'

  def forecast(lat, lon)
    params = {
      lat: lat,
      lon: lon,
      APPID: ENV['OPENWEATHER_API_KEY'], units: UNITS
    }
    response = Faraday.get(URL, params)

    unless response.success?
      Rails.logger.error "Error fetching weather: #{response.status}"
      raise "Error fetching weather: #{response.status}"
    end

    JSON.parse(response.body)
  rescue Faraday::Error => e
    Rails.logger.error "Faraday error: #{e.message}"
    raise
  end
end
