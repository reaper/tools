#!/usr/bin/env ruby

require "open-uri"
require "nokogiri"
require "byebug"


index = 1
pages_num = 1

leboncoin_baseurl = "http://www.leboncoin.fr/ventes_immobilieres/offres/alsace/bas_rhin/?o=#{pages_num}&ps=9&pe=12&sqs=11&ret=1&ret=3"
doc = Nokogiri::HTML(open(leboncoin_baseurl))

for element in doc.css("nav ul.paging")
  for element_attr in element.attributes
    pages = element_attr.last.value.scan(/left-(\d+)/)
    pages_num = pages.flatten.first.to_i
    break
  end
end


pages_num.times do |page_num|
  leboncoin_baseurl = "http://www.leboncoin.fr/ventes_immobilieres/offres/alsace/bas_rhin/?o=#{page_num}&ps=9&pe=12&sqs=11&ret=1&ret=3"
  doc = Nokogiri::HTML(open(leboncoin_baseurl))

  for element in doc.css("div.list-lbc div.lbc") do
    puts "\n========================================"

    for child_element in element.children
      if child_element.name.eql? "div"
        for child_attribute in child_element.attributes
          attr_class = child_attribute.last

          if attr_class.name.eql?("class") && attr_class.value.eql?("date")
            date = String.new

            child_div_elements = child_element.css("div")
            for date_child_element in child_div_elements
              if date_child_element == child_div_elements.last
                date.concat(date_child_element.text)
              else
                date.concat(date_child_element.text).concat(" à ")
              end

            end

            puts date
          end

          if attr_class.name.eql?("class") && attr_class.value.eql?("image")
            child_img_elements = child_element.css("img")
            for img_child_element in child_img_elements
              puts "Image: " + img_child_element.attributes["src"]
            end

            child_nb_images_elements = child_element.css("div.value.radius")
            for nb_images_child_element in child_nb_images_elements
              puts nb_images_child_element.text + " images"
            end
          end

          if attr_class.name.eql?("class") && attr_class.value.eql?("detail")
            child_h2_title_elements = child_element.css("h2.title")
            for title_child_element in child_h2_title_elements
              puts title_child_element.text.strip
            end

            child_placement_elements = child_element.css("div.placement")
            for placement_child_element in child_placement_elements
              puts placement_child_element.text.gsub(/\n|\t|\s/, "").strip
            end

            child_price_elements = child_element.css("div.price")
            for price_child_element in child_price_elements
              puts price_child_element.text.strip
            end
          end
        end
      end
    end
  end
end
