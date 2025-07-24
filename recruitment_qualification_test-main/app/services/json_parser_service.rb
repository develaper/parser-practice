class JsonParserService < BaseParserService
  # Service initiates with the file content of spec/fixtures/data.json

  private

  def extract_listings
    JSON.parse(data).map do |item|
      title, episode_number = extract_title_and_episode(item['title'])
      
      ListingData.new(
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

  def extract_title_and_episode(title)
    if title.match(/\((\d+)\)$/)
      episode_number = $1.to_i
      clean_title = title.gsub(/\s*\(\d+\)$/, '')
      [clean_title, episode_number]
    else
      [title, nil]
    end
  end
end
