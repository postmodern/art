#!/usr/bin/env ruby

# require 'chunky_png'
require 'oily_png'
require 'io/console'

unless ARGV.length == 2 || ARGV.length == 3
  $stderr.puts "usage: #{File.extname($0)} INPUT [!]COLOR [OUTPUT]"
  exit -1
end

input  = ARGV[0]
color  = ARGV[1]
output = ARGV[2] || input
rows, columns = IO.console.winsize

color_matcher = if color.start_with?('!')
                  color = ChunkyPNG::Color(color[1..-1])
                  lambda { |other_color| color != other_color }
                else
                  color = ChunkyPNG::Color(color)
                  lambda { |other_color| color == other_color }
                end

png = ChunkyPNG::Image.from_file(input)

pixels_per_row    = png.height / rows
pixels_per_column = png.width / columns

png.height.times do |y|
  png.width.times do |x|
    if color_matcher[png[x,y]]
      png[x,y] = ChunkyPNG::Color::TRANSPARENT
    end

    if (((y+1) % pixels_per_row) == 0) &&
       (((x+1) % pixels_per_column) == 0)
      print '.'
    end
  end
end

png.save(output)
