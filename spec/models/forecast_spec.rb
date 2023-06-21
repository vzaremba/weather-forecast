require 'rails_helper'

RSpec.describe Forecast, type: :model do
  let(:forecast_data) do
    JSON.parse(File.read(Rails.root.join('spec/fixtures/open_weather_response.json')))
  end

  subject { described_class.new(forecast_data) }

  describe '#current_temperature' do
    it 'returns the current temperature' do
      expect(subject.current_temperature).to eq(forecast_data['list'][0]['main']['temp'])
    end
  end

  describe '#high_temperature' do
    it 'returns the maximum temperature for the next 24 hours' do
      next_24h_temps = forecast_data['list'].first(8).map { |f| f['main']['temp'] }
      expect(subject.high_temperature).to eq(next_24h_temps.max)
    end
  end

  describe '#low_temperature' do
    it 'returns the minimum temperature for the next 24 hours' do
      next_24h_temps = forecast_data['list'].first(8).map { |f| f['main']['temp'] }
      expect(subject.low_temperature).to eq(next_24h_temps.min)
    end
  end

  describe '#five_day_forecast' do
    it 'returns the forecast for the next 5 days at midday' do
      midday_forecasts = forecast_data['list'].each_slice(8).map { |s| s[4] }.compact.first(5) # Add .compact
      expected_forecasts = midday_forecasts.map do |f|
        { date: f['dt_txt'], temp: f['main']['temp'], description: f['weather'].first['description'] }
      end

      expect(subject.five_day_forecast).to eq(expected_forecasts)
    end

    context 'when the forecast data is incomplete' do
      it 'does not raise an error' do
        expect { subject.five_day_forecast }.not_to raise_error
      end

      it 'returns as much forecast data as available' do
        expected_forecasts = forecast_data['list'].each_slice(Forecast::FORECAST_INTERVALS_PER_DAY).map { |s| s[4] }.compact.first(5).map do |f|
          { date: f['dt_txt'], temp: f['main']['temp'], description: f['weather'].first['description'] }
        end

        expect(subject.five_day_forecast).to eq(expected_forecasts)
      end
    end
  end
end
