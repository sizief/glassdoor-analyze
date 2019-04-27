#!/usr/bin/ruby
require 'yaml'
require_relative 'listings'
require_relative 'pages'
require_relative 'analyze'
require_relative 'chart'

def analyze
  list = YAML.load_file('config.yml')['urls']

  list.each do |url|
    el = url.split(';')
    # store id for each advertisement
    listing = Listings.new(title: el[0], url: el[1], key: el[2], verbose: true).run

    # store each advertisement
    page = Pages.new(title: el[0].downcase, ids_file: "./ids/#{el[0].downcase}").run

    # Analyze and generate yml files for each city
    Analyze.new(city: el[0].downcase).run

    # Generate chart
    res = YAML.load_file("./result/#{el[0].downcase}.yml")
    res.keys.each do |category|
      Chart.create(city: el[0], data: res[category], address: "./result/#{el[0].downcase}-#{category}")
    end
  end
end

def analyze_all_cities
  result = {}

  YAML.load_file('config.yml')['category'].map { |x| result[x] = {} }
  Dir['./result/*.yml'].each do |file|
    res = YAML.load_file(file)
    res.keys.each do |category|
      res[category].keys.each do |keyword|
        result[category][keyword] = 0 if result[category][keyword].nil?
        result[category][keyword] += res[category][keyword]
      end
    end
  end
  result.keys.each do |category|
    Chart.create(city: 'All cities', data: result[category], address: "./result/total-#{category}")
  end
end

analyze_all_cities
