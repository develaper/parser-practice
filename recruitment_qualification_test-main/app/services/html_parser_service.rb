class HtmlParserService < BaseParserService
  # Service initiates with the file content of spec/fixtures/data.html

  TIME_REGEX = /(\d+):(\d+)/
  TIME_RANGE_REGEX = /(\d+):(\d+)-(\d+):(\d+)/
  SEASON_EPISODE_REGEX = /S(\d+)E(\d+)/
  BASE_DATE = Date.new(2023, 1, 2)
  DEFAULT_DURATION = 1.hour

  private

  def extract_listings
    document = Nokogiri::HTML(data)
    sections = document.xpath("//section")
    
    sections.map.with_index do |section, index|
      time_element = section.xpath(".//time").text
      title_element = section.xpath(".//strong").text
      description_element = section.xpath(".//p").text
      image_element = section.xpath(".//img").first&.attribute('src')&.value
      
      # Parse season and episode from small element (format: S234E2)
      small_element = section.xpath(".//small").text
      season_number, episode_number = extract_season_and_episode(small_element)
      
      # Parse start time and end time
      start_time, end_time = parse_html_time(time_element, index, sections)
      
      # Decode HTML entities in description
      description = CGI.unescapeHTML(description_element)
      
      ListingData.new(
        title: title_element,
        start_time: start_time,
        end_time: end_time,
        description: description,
        image_url: image_element,
        episode_number: episode_number,
        season_number: season_number
      )
    end
  end

  def extract_season_and_episode(text)
    if match = text.match(SEASON_EPISODE_REGEX)
      [match[1].to_i, match[2].to_i]
    else
      [nil, nil]
    end
  end

  def parse_html_time(time_text, current_index, sections)
    if match = time_text.match(TIME_RANGE_REGEX)
      return parse_time_range_with_match(match)
    end
    
    parse_single_time(time_text, current_index, sections)
  end

  def parse_time_range_with_match(match)
    start_hour, start_minute = match[1].to_i, match[2].to_i
    end_hour, end_minute = match[3].to_i, match[4].to_i
    
    start_time = build_time(start_hour, start_minute)
    end_time = build_time(end_hour, end_minute)
    
    [start_time, end_time]
  end

  def parse_single_time(time_text, current_index, sections)
    match = time_text.match(TIME_REGEX)
    start_hour, start_minute = match[1].to_i, match[2].to_i
    start_time = build_time(start_hour, start_minute)
    
    end_time = calculate_end_time(current_index, sections, start_time)
    
    [start_time, end_time]
  end

  def build_time(hour, minute)
    Time.new(BASE_DATE.year, BASE_DATE.month, BASE_DATE.day, hour, minute, 0, '+00:00')
  end

  def calculate_end_time(current_index, sections, default_start_time)
    next_section = sections[current_index + 1]
    
    if next_section
      next_time_text = next_section.xpath(".//time").text
      if match = next_time_text.match(TIME_REGEX)
        next_hour, next_minute = match[1].to_i, match[2].to_i
        return build_time(next_hour, next_minute)
      end
    end
    
    default_start_time + DEFAULT_DURATION
  end
end
