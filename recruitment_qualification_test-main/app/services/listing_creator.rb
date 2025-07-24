class ListingCreator
  def self.create(listing_data)
    attributes = listing_data.respond_to?(:to_h) ? listing_data.to_h : listing_data
    
    Listing.create!({
      title: attributes[:title],
      start_time: attributes[:start_time],
      end_time: attributes[:end_time],
      description: attributes[:description],
      image_url: attributes[:image_url],
      episode_number: normalize_number(attributes[:episode_number]),
      season_number: normalize_number(attributes[:season_number])
    })
  end

  private

  def self.normalize_number(value)
    value&.zero? ? nil : value
  end
end
