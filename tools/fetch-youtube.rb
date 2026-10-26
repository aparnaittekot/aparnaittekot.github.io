#!/usr/bin/env ruby
#
# Fetch every public video in the playlists listed under youtube.sections in _config.yml
# from the YouTube Data API and write them to _data/youtube.json, which the Music page,
# the home page and the search read. Run daily by .github/workflows/youtube-videos.yml.
#
# Usage: YOUTUBE_API_KEY=... ruby tools/fetch-youtube.rb
#   YOUTUBE_REFERER (optional) is sent as the Referer header, for running it locally
#   with a key that is restricted to certain websites.

require 'json'
require 'net/http'
require 'time'
require 'yaml'

ROOT = File.expand_path('..', __dir__)
OUTPUT = File.join(ROOT, '_data', 'youtube.json')
API = 'https://www.googleapis.com/youtube/v3/'

API_KEY = ENV['YOUTUBE_API_KEY'].to_s
abort 'YOUTUBE_API_KEY is not set' if API_KEY.empty?

def get(path, params)
  uri = URI(API + path)
  uri.query = URI.encode_www_form(params.merge(key: API_KEY))
  request = Net::HTTP::Get.new(uri)
  request['Referer'] = ENV['YOUTUBE_REFERER'] if ENV['YOUTUBE_REFERER']
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 20) do |http|
    http.request(request)
  end
  body = JSON.parse(response.body)
  # Stop on any error so a bad run never replaces the saved list with a partial one
  abort "YouTube API #{response.code}: #{body.dig('error', 'message')}" unless response.is_a?(Net::HTTPSuccess)
  body
end

# All public videos in a playlist; the API returns 50 per page
def playlist_videos(playlist_id)
  items = []
  page_token = nil
  loop do
    params = { part: 'snippet,status,contentDetails', maxResults: 50, playlistId: playlist_id }
    params[:pageToken] = page_token if page_token
    data = get('playlistItems', params)
    items.concat(data['items'])
    page_token = data['nextPageToken']
    break unless page_token
  end

  items.filter_map do |item|
    published = item.dig('contentDetails', 'videoPublishedAt')
    next unless item.dig('status', 'privacyStatus') == 'public' && published

    id = item.dig('contentDetails', 'videoId')
    title = item.dig('snippet', 'title').to_s
    clean_title = title.gsub(/\s*#\S+/, '').strip # drop hashtags for the tiles
    {
      'id' => id,
      'title' => clean_title.empty? ? title : clean_title,
      'url' => "https://www.youtube.com/watch?v=#{id}",
      'thumbnail' => "https://i.ytimg.com/vi/#{id}/hqdefault.jpg",
      'published' => Time.parse(published).utc.iso8601
    }
  end
end

config = YAML.load_file(File.join(ROOT, '_config.yml'))
sections = config.dig('youtube', 'sections') || []
abort 'No youtube.sections in _config.yml' if sections.empty?

playlist_ids = sections.flat_map { |s| Array(s['playlists']) }.uniq
playlist_titles = get('playlists', { part: 'snippet', id: playlist_ids.join(','), maxResults: 50 })['items']
                  .to_h { |p| [p['id'], p.dig('snippet', 'title')] }

result = sections.map do |section|
  prefix = section['label_prefix']
  videos = Array(section['playlists']).flat_map do |playlist_id|
    name = playlist_titles[playlist_id].to_s
    label = prefix && name.start_with?(prefix) ? name.delete_prefix(prefix).strip : nil
    playlist_videos(playlist_id).map { |video| video.merge('label' => label) }
  end

  {
    'id' => section['id'],
    'title' => section['title'],
    'videos' => videos.uniq { |v| v['id'] }.sort_by { |v| v['published'] }.reverse
  }
end

File.write(OUTPUT, "#{JSON.pretty_generate(result)}\n")
puts result.map { |s| "#{s['title']}: #{s['videos'].size}" }.join(', ')
