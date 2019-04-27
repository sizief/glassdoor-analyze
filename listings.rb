class Listings
  require 'rest-client'
  require 'nokogiri'
  require 'open-uri'
  require 'json'
  require 'fileutils'
  require 'colorize'
  require 'yaml'

  require_relative 'logging'

  include Logging

  def initialize(args)
    @pages = 1000
    @title = args[:title].downcase
    @url = args[:url].strip
    @key = args[:key].strip
    @destination = "./ids/#{@title}"
    @job_types = YAML.load_file('config.yml')['job_types']
  end

  def run
    logger.warn '-- start --'
    return if File.file? @destination

    FileUtils.mkdir_p('ids')
    save_to_file @url, @title
    logger.warn '-- Done --'
  end

  private

  def save_to_file(url, title)
    data = extract_data url
    file = "./ids/#{title}"
    FileUtils.touch(file)
    store = File.open(file, 'w')
    store.puts data.join(',')
    store.close
    logger.info 'logged all ids to file'
  end

  def extract_data(master_url)
    listing_ids = []
    begin
      @job_types.each do |job_type|
        (1..@pages).each do |page_number|
          logger.info master_url.green
          url = "#{master_url}-#{job_type}-#{@key}#{page_number}.htm"
          json_string = get_data url
          # logger.debug "#{url} \n #{json_string} \n".green
          break if /\d/.match(json_string).nil? # no more pages exists

          listing_ids << json_string.gsub(/\s+/, '').delete("'").split(',').map(&:to_i)
          # logger.debug listing_ids.inspect.green
        end
      end
    rescue StandardError => e
      logger.warn "something wrong here #{e}".red
    end
    listing_ids.flatten.uniq
  end

  def get_data(url)
    logger.info "connecting to url #{url}"
    doc = Nokogiri::HTML(open(url))
    script = doc.css('script')[0]
    script.content.scan(/\jobIds':\[(.*?)\]/m).first.first
  end
end
