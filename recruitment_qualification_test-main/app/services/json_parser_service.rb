class JsonParserService
  attr_reader :data

  # Service initiates with the file content of spec/fixtures/data.json
  def initialize(data)
    @data = data
  end

  def parse
    json_data = JSON.parse(data)
    
    json_data.each do |item|
      title = item['title']
      episode_number = nil
      
      if title.match(/\((\d+)\)$/)
        episode_number = $1.to_i
        title = title.gsub(/\s*\(\d+\)$/, '')
      end
      
      Listing.create!(
        title: title,
        start_time: item.dig('schedule', 'start'),
        end_time: item.dig('schedule', 'stop'),
        description: item['description'],
        image_url: item['image'],
        episode_number: episode_number,
        season_number: item['season']
      )
    end
  end
end
