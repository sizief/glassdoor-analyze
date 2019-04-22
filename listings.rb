class Listings

require 'rest-client'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'fileutils'
require 'colorize'

def initialize args
  @pages = 1000
  @logger = Logger.new(STDOUT)
  @logger.level = Logger::INFO if args[:verbose]
  @title = args[:title].downcase
  @url = args[:url].strip
  @destination = "./ids/#{@title}"
end

def run
  @logger.info("-- start --")
  return if File.file? @destination
  FileUtils.mkdir_p('ids')
  save_to_file @url, @title
  @logger.info("-- Done --")
end

private

def save_to_file url, title
  data = extract_data url
  file = "./ids/#{title}"
  FileUtils.touch(file)
  store = File.open(file, "w")
  store.puts data.join(",")
  @logger.info "logged all ids to file"
end

def extract_data master_url
  listing_ids = Array.new
  begin
    (1..@pages).each do |page_number|
      @logger.info master_url.green
      url = master_url + "#{page_number}.htm"
      json_string = get_data url
      @logger.debug "#{url} \n #{json_string} \n".green
      break if /\d/.match(json_string).nil? #no more pages exists
      listing_ids << json_string.gsub(/\s+/, "").gsub(/'/,"").split(",").map{|el| el.to_i}
      @logger.debug listing_ids.inspect.green
    end
  rescue => e
    @logger.warn "something wrong here #{e}".red
  end
  listing_ids.flatten.uniq
end

def get_data url
  @logger.info "connecting to url #{url}"
  doc = Nokogiri::HTML(open(url))
  @logger.debug "working on resource: #{doc}"
  script = doc.css('script')[0]
  @logger.debug "before #{script}".red
  script.content.scan(/\jobIds':\[(.*?)\]/m).first.first
end


end
