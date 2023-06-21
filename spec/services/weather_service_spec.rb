require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:lat) { 40.7128 }
  let(:lon) { -74.0060 }

  describe '#forecast' do
    let(:service) { described_class.new }
    let(:params) do
      { lat: lat, lon: lon, APPID: ENV['OPENWEATHER_API_KEY'], units: described_class::UNITS }
    end

    context 'when the API request is successful' do
      let(:body) { File.read(Rails.root.join('spec/fixtures/open_weather_response.json')) }

      before do
        stub_request(:get, described_class::URL)
          .with(query: params)
          .to_return(status: 200, body: body)
      end

      it 'returns parsed JSON response' do
        expect(service.forecast(lat, lon)).to eq(JSON.parse(body))
      end
    end

    context 'when the API request fails' do
      before do
        stub_request(:get, described_class::URL)
          .with(query: params)
          .to_return(status: 500)
      end

      it 'logs an error and raises an exception' do
        expect(Rails.logger).to receive(:error).with("Error fetching weather: 500")
        expect { service.forecast(lat, lon) }.to raise_error(RuntimeError, "Error fetching weather: 500")
      end
    end

    context 'when there is a Faraday error' do
      before do
        stub_request(:get, described_class::URL)
          .with(query: params)
          .to_raise(Faraday::Error.new("Faraday error"))
      end

      it 'logs an error and raises the original exception' do
        expect(Rails.logger).to receive(:error).with("Faraday error: Faraday error")
        expect { service.forecast(lat, lon) }.to raise_error(Faraday::Error)
      end
    end
  end
end
