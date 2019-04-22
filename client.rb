#!/usr/bin/ruby
require_relative 'listings'
require_relative 'pages'
require_relative 'analyze'

list = []
f = File.open('list', 'r')
f.each_line do |line|
  list << line.split(';')
end
f.close

list.each do |el|
  # store id for each advertisement
  listing = Listings.new(title: el[0], url: el[1], verbose: true).run

  # store each advertisement
  page = Pages.new(title: el[0].downcase, ids_file: "./ids/#{el[0].downcase}").run

  break
end

p Analyze.new(city: 'dubai').run
