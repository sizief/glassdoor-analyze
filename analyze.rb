class Analyze

require 'rest-client'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'fileutils'

def initialize args
  @city = args[:city]
  @dictionary = create_dictionary
  @logger = Logger.new(STDOUT)
  @logger.level = Logger::INFO if args[:verbose]
  #update_anagram './pages/berlin/3110045054'
  #p $dictionary.sort_by{|k,v| v}.reverse
end

def run
  analyze_all @city
end

def analyze_all city
  Dir["./pages/#{city}/*"].each do |source|
    p source
    @logger.info "#{source} is empty".red unless update_anagram source #'./pages/berlin/3065453364'
  end
  @dictionary.sort_by{|k,v| v}.reverse
end

private

def create_dictionary
  languages = %w(java javascript c c# c++ php python perl elixir go ruby nodejs scala shell sql erlang rust android kotlin)
  technologies = %w(kafka nosql puppet salt aws docker kubernetes rabiitMQ elastic RESTful mongo terraform ansible chef amazon jenkins kibana git)
  dic = Hash.new
  (languages+technologies).each do |keyword|
    dic[keyword.downcase] = 0
  end
  dic
end

def update_anagram source
  open(source).gets
  this_businues_dictionary = Hash.new
  doc = Nokogiri::HTML(open(source))
  script = doc.css('script')[10]
  #@logger.debug "Script for #{source}: #{script}"
  return false if script.nil?
  keywords = script.content.scan(/"description"\:(.*?)\}/m)
  return if keywords.first.nil? 
  keywords = keywords.first.first.gsub(/\(|\)|\\|"|,/, "").split(" ")
  keywords.each do |k|
    keyword = k.downcase 
    if @dictionary.key?(keyword)
      this_businues_dictionary[keyword] = this_businues_dictionary[keyword].nil? ? 1 : 2
      next if this_businues_dictionary[keyword] > 1
      @dictionary[keyword] += 1 
    end
  end
end
#p open("./ids/berlin-software_engineer").gets.split(",").size

end
