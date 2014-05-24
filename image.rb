require 'nokogiri'
require 'open-uri'

url = "http://pinterest.com/"

doc = Nokogiri::HTML(open(url))
#doc.xpath('img[@class="PinImageImg"]/data-src').each do |img|
doc.xpath('//img/@data-src').each do |img|
 	puts img.content 
end
