#!/usr/bin/env ruby
#
# Load YouTube videos into site.data['youtube'] at build time, grouped into sections.
# Each section reads one or more playlists' public feeds (no API key needed); a feed
# lists the playlist's 15 newest videos. Sections are set in _config.yml:
#
#   youtube:
#     sections:
#       - id: covers
#         title: Keyboard Covers
#         label_prefix: "Keyboard Covers - "   # optional: label each tile with its playlist name
#         playlists: [PL...]

require 'net/http'
require 'rexml/document'
require 'time'

module YoutubeFeed
  FEED_URL = 'https://www.youtube.com/feeds/videos.xml?playlist_id=%s'
  CACHE_SECONDS = 3600 # avoid refetching on every local rebuild

  @cache = {}

  class << self
    # Returns { 'title' => playlist name, 'videos' => [...] }
    def playlist(playlist_id)
      cached = @cache[playlist_id]
      return cached[:data] if cached && Time.now - cached[:at] < CACHE_SECONDS

      data = fetch(playlist_id)
      @cache[playlist_id] = { at: Time.now, data: data }
      data
    rescue StandardError => e
      Jekyll.logger.warn 'YouTube feed:', "could not load playlist #{playlist_id} (#{e.message})"
      cached ? cached[:data] : { 'title' => '', 'videos' => [] }
    end

    private

    def fetch(playlist_id)
      uri = URI(format(FEED_URL, playlist_id))
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 10) do |http|
        http.get(uri.request_uri)
      end
      raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      doc = REXML::Document.new(response.body)
      videos = doc.get_elements('//entry').map do |entry|
        id = entry.elements['yt:videoId'].text
        title = entry.elements['title'].text.to_s
        clean_title = title.gsub(/\s*#\S+/, '').strip # drop hashtags for the tiles
        {
          'id' => id,
          'title' => clean_title.empty? ? title : clean_title,
          'url' => "https://www.youtube.com/watch?v=#{id}",
          'thumbnail' => "https://i.ytimg.com/vi/#{id}/hqdefault.jpg",
          'published' => Time.parse(entry.elements['published'].text)
        }
      end
      { 'title' => doc.elements['feed/title']&.text.to_s, 'videos' => videos }
    end
  end

  class Generator < Jekyll::Generator
    safe true
    priority :high

    def generate(site)
      sections = site.config.dig('youtube', 'sections') || []
      return if sections.empty?

      site.data['youtube'] = sections.map do |section|
        prefix = section['label_prefix']
        videos = Array(section['playlists']).flat_map do |playlist_id|
          playlist = YoutubeFeed.playlist(playlist_id)
          label = prefix ? playlist['title'].delete_prefix(prefix).strip : nil
          playlist['videos'].map { |video| video.merge('label' => label) }
        end

        {
          'id' => section['id'],
          'title' => section['title'],
          'latest_label' => section['latest_label'],
          'videos' => videos.uniq { |v| v['id'] }.sort_by { |v| v['published'] }.reverse
        }
      end

      counts = site.data['youtube'].map { |s| "#{s['title']}: #{s['videos'].size}" }.join(', ')
      Jekyll.logger.info 'YouTube feed:', counts
    end
  end
end
