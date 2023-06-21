class GeocodingService
  def self.search(address)
    Geocoder.search(address).first
  end
end
