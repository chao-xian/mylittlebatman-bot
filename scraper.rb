require 'nokogiri'
require 'open-uri'
require 'uri'

@guide_pages = []
@all_summaries = []

# Set up the list of all guide pages to scrape
def make_guide_page_list
  puts 'Making a list of all the pages to scrape...'
  i = 0
  # There were 77 pages of summaries to scrape when I wrote this
  7.times do
    i += 1
    # page = "http://www.bbc.co.uk/programmes/b006m86d/episodes/guide?page=#{i}"
    # page = "http://www.pogdesign.co.uk/cat/My-Little-Pony-Friendship-is-Magic/Season-#{i}"
    page = "http://www.tv.com/shows/my-little-pony-friendship-is-magic/season-#{i}/"
    @guide_pages << page
  end
end

# Scrape the pages for plot summaries
def scrape(page)
  html = open(page)
  doc = Nokogiri::HTML(html)

  # Get each episode summary
  # doc.css('.programme__synopsis span').each do |summary|
  doc.css('div.description').each do |summary|
    # Add the summary text to the main array
    @all_summaries << summary.text
  end
end

# Write summaries to txt file
def write_to_txt
  # Create unique filename based on time
  filename = "ponyville_#{Time.now.strftime('%l%m%M%S%w%y')}.txt"

  File.open("corpus/#{filename}", 'w+') do |file|
    puts "Writing to #{filename}..."
    @all_summaries.each do |summary|
      file.write(summary)
      file.write("\n")
    end
  end
end

make_guide_page_list

@guide_pages.each do |page|
  puts "Scraping #{page}"
  scrape(page)
end

write_to_txt

puts 'Done!'
