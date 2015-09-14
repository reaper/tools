#!/usr/bin/env ruby

require "rubygems"
require "simple-rss"
require "open-uri"
require "byebug"
require "ostruct"

config = YAML.load_file("rss_download.yml")

for feed in config["rss_feeds"]
  url_rss = SimpleRSS.parse open(feed["url"])

  for rss_item in url_rss.items
    for item in feed["items"]
      should_dl = true

      for tag in item["tags"]
        unless rss_item.title.downcase.include?(tag.downcase)
          should_dl = false
          break
        end
      end

      break if should_dl
    end

    if should_dl
      puts "Downloading #{rss_item[:title]}"
    end
  end
end
