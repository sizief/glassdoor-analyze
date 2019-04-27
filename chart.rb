module Chart
  require 'gruff'

  def self.create(args)
    sorted_array = args[:data].sort_by { |_k, v| v }.reverse

    labels = {}
    values = []
    sorted_array.each_with_index do |el, index|
      labels[index] = el[0].capitalize
      values << el[1].to_i
    end

    g = Gruff::SideBar.new(1200)
    city = args[:city]
    city = 'Newyork' if city == 'New_york'
    city = 'Bay area' if city == 'Bay_area'
    g.title = city

    g.data 'Number of Glassdoor job ads that mention each keyword', values
    g.labels = labels
    g.show_labels_for_bar_values = true
    g.write("#{args[:address]}.png")
  end
end
