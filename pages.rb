class Pages

require 'rest-client'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'fileutils'
require 'net/http'

def initialize args
  @title = args[:title]
  @ids_file = args[:ids_file]
  @sleep = 1
  @logger = Logger.new(STDOUT)
  @logger.level = Logger::INFO if args[:verbose]
end

def run
  destination = "pages/#{@title}"
  FileUtils.mkdir_p(destination)
  save_all destination, @ids_file
end

private

def save_to file_path, id
  @logger.info "going to create #{file_path}".green
  return false if File.file?(file_path)
  FileUtils.touch(file_path)
  store = File.open(file_path, "w")
  url = 'https://www.glassdoor.de/job-listing/software-engineer-codeship-frontend-cloudbees-JV_IC2622109_KO2.htm?jl='+id
  @logger.info "trying #{url}"
  store.puts Net::HTTP.get(URI.parse(url))
  @logger.info "#{url} done!".green
end

def save_all destination, ids_file
  list = open(ids_file).gets.split(",")
  listing_ids = Array.new
  counter = 0
  begin
    list.each do |id|
      @logger.info "#{counter} of #{list.size}"
      file_path = "./#{destination}/#{id}"
      sleep @sleep if  save_to file_path.strip, id.strip
      counter +=1
    end
  rescue => e
    @logger.warn "can not save: #{e}"
  end
end

end
