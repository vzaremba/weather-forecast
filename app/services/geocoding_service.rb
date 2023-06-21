class GeocodingService
  def self.search(address)
    return if address.blank?
    Geocoder.search(address).first
  end
end
