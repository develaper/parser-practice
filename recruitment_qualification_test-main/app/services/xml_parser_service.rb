class XmlParserService
  attr_reader :data

  # Service initiates with the file content of spec/fixtures/data.xml
  def initialize(data)
    @data = data
  end

  def parse
    document = Nokogiri::XML(data)
    
    document.xpath("//listing").each do |listing|
      date = listing.attribute('date').value
      start_time_str = listing.attribute('start').value
      stop_time_str = listing.attribute('stop').value
      
      start_time = parse_cet_to_utc(date, start_time_str)
      end_time = parse_cet_to_utc(date, stop_time_str)
      
      episode_node = listing.xpath('episode').first
      episode_number = episode_node&.text&.to_i
      season_number = episode_node&.attribute('season')&.value&.to_i
      
      Listing.create!(
        title: listing.xpath('title').text,
        start_time: start_time,
        end_time: end_time,
        description: listing.xpath('description').text,
        image_url: listing.xpath('image').text,
        episode_number: episode_number,
        season_number: season_number
      )
    end
  end
  
  private
  
  def parse_cet_to_utc(date, time)
    # CET is UTC+1, so we need to subtract 1 hour to get UTC
    datetime_str = "#{date}T#{time}+01:00"
    Time.parse(datetime_str).utc
  end
end
