# spec/services/geocoding_service_spec.rb
require 'rails_helper'

RSpec.describe GeocodingService do
  describe '.search' do
    before do
      allow(Geocoder).to receive(:search).and_return([OpenStruct.new(data: 'Mock data')])
    end

    context 'when a valid address is provided' do
      it 'calls Geocoder.search with the correct arguments' do
        described_class.search('123 Main St')
        expect(Geocoder).to have_received(:search).with('123 Main St')
      end

      it 'returns the first result from Geocoder.search' do
        result = described_class.search('123 Main St')
        expect(result.data).to eq('Mock data')
      end
    end

    context 'when an empty address is provided' do
      it 'returns nil' do
        result = described_class.search('')
        expect(result).to be_nil
      end
    end

    context 'when an invalid address is provided' do
      before do
        allow(Geocoder).to receive(:search).and_return([])
      end

      it 'returns nil' do
        result = described_class.search('!@#$%^&*()')
        expect(result).to be_nil
      end
    end
  end
end
