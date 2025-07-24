class BaseParserService
  attr_reader :data

  def initialize(data, listing_creator = ListingCreator)
    @data = data
    @listing_creator = listing_creator
  end

  def parse
    extract_listings.each do |listing_data|
      @listing_creator.create(listing_data)
    end
  end

  private

  def extract_listings
    raise NotImplementedError, "Subclasses must implement extract_listings method"
  end
end
