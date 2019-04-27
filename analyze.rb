class Analyze
  require 'rest-client'
  require 'nokogiri'
  require 'open-uri'
  require 'json'
  require 'fileutils'
  require 'yaml'
  require_relative 'logging'

  include Logging

  def initialize(args)
    @city = args[:city]
  end

  def run
    data = analyze_all @city
    FileUtils.mkdir_p('result')
    save_to_file data, @city
  end

  private

  def save_to_file(data, city)
    file = "./result/#{city}.yml"
    # FileUtils.touch(file)
    store = File.open(file, 'w')
    store.puts data
    store.close
  end

  def analyze_all(city)
    dictionary = create_dictionary
    Dir["./pages/#{city}/*"].each do |source|
      logger.info source
      res = update_anagram source, dictionary
      if res[:status]
        dictionary = res[:message]
      else
        logger.info "#{source} is empty".red
      end
    end
    dictionary.to_yaml
  end

  def create_dictionary
    keyword_list = []
    dictionary = {}

    config = YAML.load_file('config.yml')
    (config['category']).each do |category|
      dictionary[category] = {}
      (config[category]).each do |keyword|
        dictionary[category][keyword.downcase] = 0
      end
    end
    dictionary
  end

  def update_anagram(source, dictionary)
    open(source).gets
    business_dictionary = {}
    doc = Nokogiri::HTML(open(source))
    script = doc.css('script')[10]
    return { status: false } if script.nil?

    keywords = script.content.scan(/"description"\:(.*?)\}/m)
    return { status: false } if keywords.first.nil?

    keywords = keywords.first.first.gsub(/\(|\)|\\|"|,/, '').split(' ')
    { status: true, message: update_hash(dictionary, business_dictionary, keywords) }
  end

  def update_hash(dictionary, business_dictionary, keywords)
    keywords.each do |keyword|
      keyword = keyword[0..keyword.index('&') - 1] unless keyword.index('&').nil?
      keyword.downcase!
      category = find_category dictionary, keyword

      next if category.nil?
      next if business_dictionary.key?(keyword)

      business_dictionary[keyword] = 1
      dictionary[category][keyword] += 1
    end
    dictionary
  end

  def find_category(dictionary, keyword)
    category = nil
    dictionary.keys.each do |config_category|
      category = config_category if dictionary[config_category].key?(keyword)
    end
    category
  end
end
