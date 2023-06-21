require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  render_views

  let(:address) { "60062" }

  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    context "when the address can be geocoded and forecast data is available" do
      before do
        allow(GeocodingService).to receive(:search).and_return(double(data: {'lat' => '1.1', 'lon' => '2.2'}, address: "60062", coordinates: ['1.1', '2.2']))
        allow(WeatherService).to receive(:new).and_return(double(forecast: {}))
        allow(Forecast).to receive(:new).and_return(double(current_temperature: 70, high_temperature: 75, low_temperature: 65, five_day_forecast: []))
      end

      it "renders the show template and assigns the forecast" do
        get :show, params: { address: address }, format: :turbo_stream
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        expect(assigns(:location)).not_to be_nil
        expect(assigns(:from_cache)).to be_falsey
        expect(assigns(:forecast)).not_to be_nil
        expect(assigns(:error)).to be_nil
      end

      it "caches the forecast data" do
        expect(Rails.cache).to receive(:fetch).with("forecast_1.1_2.2", expires_in: 30.minutes).and_call_original
        get :show, params: { address: address }, format: :turbo_stream
      end
    end

    context "when the address cannot be geocoded" do
      before do
        allow(GeocodingService).to receive(:search).and_return(nil)
      end

      it "renders the show template with an error message" do
        get :show, params: { address: address }, format: :turbo_stream
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        expect(assigns(:location)).to be_nil
        expect(assigns(:from_cache)).to be_nil
        expect(assigns(:forecast)).to be_nil
        expect(assigns(:error)).to eq("Error geocoding address: #{address}")
      end
    end

    context "when an error occurs during weather fetching" do
      before do
        allow(GeocodingService).to receive(:search).and_return(double(data: {'lat' => '1.1', 'lon' => '2.2'}, address: "60062", coordinates: ['1.1', '2.2']))
        allow(WeatherService).to receive(:new).and_raise("Weather fetch error")
      end

      it "renders the show template with an error message" do
        expect(Rails.logger).to receive(:error).with(/Error fetching weather for coordinates: \[\"1.1\", \"2.2\"\]/).twice
        get :show, params: { address: address }, format: :turbo_stream
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        expect(assigns(:location)).not_to be_nil
        expect(assigns(:from_cache)).to be_falsey
        expect(assigns(:forecast)).to be_nil
        expect(assigns(:error)).to eq("Error fetching weather for coordinates: [\"1.1\", \"2.2\"]")
      end
    end

    context "when the forecast data is already cached" do
      let(:forecast_data) do
        {
          'list' => [
            { 'dt_txt' => '2023-06-22 12:00:00', 'main' => { 'temp' => 70, 'temp_max' => 75, 'temp_min' => 65 }, 'weather' => [{'description' => 'clear sky'}] },
            { 'dt_txt' => '2023-06-23 12:00:00', 'main' => { 'temp' => 73, 'temp_max' => 77, 'temp_min' => 68 }, 'weather' => [{'description' => 'few clouds'}] },
            { 'dt_txt' => '2023-06-24 12:00:00', 'main' => { 'temp' => 72, 'temp_max' => 76, 'temp_min' => 67 }, 'weather' => [{'description' => 'scattered clouds'}] },
            { 'dt_txt' => '2023-06-25 12:00:00', 'main' => { 'temp' => 74, 'temp_max' => 78, 'temp_min' => 69 }, 'weather' => [{'description' => 'broken clouds'}] },
            { 'dt_txt' => '2023-06-26 12:00:00', 'main' => { 'temp' => 71, 'temp_max' => 75, 'temp_min' => 66 }, 'weather' => [{'description' => 'light rain'}] }
          ]
        }
      end

      before do
        allow(GeocodingService).to receive(:search).and_return(double(data: {'lat' => '1.1', 'lon' => '2.2'}, address: "60062", coordinates: ['1.1', '2.2']))
        allow(WeatherService).to receive(:new).and_return(double(forecast: {}))
        allow(Rails.cache).to receive(:exist?).and_return(true)
        allow(Rails.cache).to receive(:fetch).and_return(forecast_data)
      end

      it "retrieves the forecast data from the cache" do
        get :show, params: { address: address }, format: :turbo_stream
        expect(response).to have_http_status(:success)
        expect(assigns(:from_cache)).to be_truthy
      end
    end

    context "when an error is returned from WeatherService" do
      before do
        allow(GeocodingService).to receive(:search).and_return(double(data: {'lat' => '1.1', 'lon' => '2.2'}, address: "60062", coordinates: ['1.1', '2.2']))
        allow(WeatherService).to receive(:new).and_raise("Weather service error")
      end

      it "renders the show template with an error message" do
        get :show, params: { address: address }, format: :turbo_stream
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        expect(assigns(:location)).not_to be_nil
        expect(assigns(:from_cache)).to be_falsey
        expect(assigns(:forecast)).to be_nil
        expect(assigns(:error)).to eq("Error fetching weather for coordinates: [\"1.1\", \"2.2\"]")
      end
    end
  end
end
