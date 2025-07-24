class ListingData
  attr_reader :title, :start_time, :end_time, :description, :image_url, :episode_number, :season_number

  def initialize(title:, start_time:, end_time:, description:, image_url:, episode_number: nil, season_number: nil)
    @title = title
    @start_time = start_time
    @end_time = end_time
    @description = description
    @image_url = image_url
    @episode_number = episode_number
    @season_number = season_number
  end

  def to_h
    {
      title: title,
      start_time: start_time,
      end_time: end_time,
      description: description,
      image_url: image_url,
      episode_number: episode_number,
      season_number: season_number
    }
  end
end
