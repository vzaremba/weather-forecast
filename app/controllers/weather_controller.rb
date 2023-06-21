class WeatherController < ApplicationController
  def index
  end

  def show
    address = params[:address]
    coordinates = Geocoder.coordinates(address)
    @location = Geocoder.search(address).first
  end
end
