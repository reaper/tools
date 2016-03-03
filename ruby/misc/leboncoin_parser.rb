#!/usr/bin/env ruby

require "open-uri"
require "nokogiri"
require "byebug"


index = 1
pages_num = 1

leboncoin_baseurl = "http://www.leboncoin.fr/ventes_immobilieres/offres/alsace/bas_rhin/?o=#{pages_num}&ps=9&pe=12&sqs=11&ret=1&ret=3"
doc = Nokogiri::HTML(open(leboncoin_baseurl))

pages_num.times do |page_num|
  leboncoin_baseurl = "http://www.leboncoin.fr/ventes_immobilieres/offres/alsace/bas_rhin/?o=#{page_num}&ps=9&pe=12&sqs=11&ret=1&ret=3"
  doc = Nokogiri::HTML(open(leboncoin_baseurl))

  for element in doc.css("#main #listingAds .list ul.tabsContent li") do
    puts "\n========================================"

    link = element.css("a.list_item").attr("href")
    title = element.css(".item_infos h2.item_title").text.strip

    supp = []
    for item in element.css(".item_infos p.item_supp")
      text = item.text.strip
      text = text.gsub(/(\s+\/\s+)/, " / ")
      supp << text
    end

    puts link
    puts title
    supp.each {|e| puts e}
  end
end
