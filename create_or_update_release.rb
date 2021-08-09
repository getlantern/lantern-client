#!/usr/bin/env ruby

if ARGV.length < 4
  abort "\nUsage create_or_update_release.rb $user $GH_repo $TAG $FILE_NAME\n\n"
end

require "net/https"
require "json"
require 'octokit'

user=ARGV[0]
repo=ARGV[1]
tag=ARGV[2]
filenames=ARGV.slice(3, 1000)

gh_token=ENV['GH_TOKEN']

@client = Octokit::Client.new(:access_token => gh_token)

# First create the release if necessary
uri = URI("https://api.github.com")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new("/repos/#{user}/#{repo}/releases")
request["Accept"] = "application/vnd.github.v3+json"
request["Authorization"] = "token #{gh_token}"
request.body = {
  "tag_name"         => tag,
  "target_commitish" => "",
  "name"             => tag,
  "body"             => "",
  "draft"            => false,
  "prerelease"       => false,
}.to_json

response = http.request(request)

if response.body.include? "already_exists"
  puts "* Release already exists. No worries, we'll just delete existing assets..."
  releases = @client.releases "#{user}/#{repo}"
  target_release = releases.select { |r| r.tag_name == tag }[0]
  
  if not target_release.empty?
    assets = @client.release_assets(target_release.url)
    assets_to_delete = assets.select { |a| filenames.include?(a.name) }
    assets_to_delete.each do |asset|
      $stderr.puts "* Removing #{asset.name} (#{asset.content_type})..."
      @client.delete_release_asset(asset.url)
    end
  end
else
  abort response.body unless response.is_a?(Net::HTTPSuccess)
end

# Then upload the assets
filenames.each do |filename|
  begin
    #ct = MIME::Types.of(file).first || "application/octet-stream"
    @client.upload_asset(target_release.url, filename)
  rescue Octokit::UnprocessableEntity
    abort "\nAsset already exists? Should never happen\n"
  end
end