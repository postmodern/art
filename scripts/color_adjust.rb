#!/usr/bin/env ruby

# require 'chunky_png'
require 'oily_png'
require 'io/console'

unless ARGV.length == 2 || ARGV.length == 3
  $stderr.puts "usage: #{File.extname($0)} INPUT ORIG_COLOR NEW_COLOR [OUTPUT]"
  exit -1
end

input      = ARGV[0]
orig_color = ChunkyPNG::Color(ARGV[1])
new_color  = ChunkyPNG::Color(ARGV[2])
output     = ARGV[2] || input
rows, columns = IO.console.winsize

png = ChunkyPNG::Image.from_file(input)

pixels_per_row    = png.height / rows
pixels_per_column = png.width / columns

png.height.times do |y|
  png.width.times do |x|
    if png[x,y] == orig_color
      png[x,y] = new_color
    end

    if (((y+1) % pixels_per_row) == 0) &&
       (((x+1) % pixels_per_column) == 0)
      print '.'
    end
  end
end

png.save(output)
