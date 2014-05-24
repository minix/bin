#!/usr/bin/env ruby
#
require 'nokogiri'
require 'open-uri'
require 'uri'

doc = Nokogiri::HTML(open(ARGV[0]))
image_url = doc.at_css('meta[property="og:image"]')['content']

file_name = URI(image_url).path.split('/').last
File.open("#{file_name}", 'wb') do |fo|
	fo.write open(image_url).read
end

