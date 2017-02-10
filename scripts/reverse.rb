#!/usr/bin/env ruby

# require 'chunky_png'
require 'oily_png'
require 'io/console'

unless ARGV.length == 2 || ARGV.length == 3
  $stderr.puts "usage: #{File.extname($0)} INPUT [OUTPUT]"
  exit -1
end

input  = ARGV[0]
output = ARGV[1] || File.basename(input).sub(/\.png$/,' - reversed.png')
rows, columns = IO.console.winsize

png = ChunkyPNG::Image.from_file(input)

pixels_per_row    = png.height / rows
pixels_per_column = png.width / columns

png.height.times do |y|
  (png.width / 2).times do |x1|
    x2 = (png.width - x1) - 1

    pixel1 = png[x1,y]
    pixel2 = png[x2,y]

    next if pixel1 == ChunkyPNG::Color::TRANSPARENT &&
            pixel2 == ChunkyPNG::Color::TRANSPARENT

    png[x1,y] = pixel2
    png[x2,y] = pixel1

    if (((y+1) % pixels_per_row) == 0) &&
       (((x1+1) % pixels_per_column) == 0)
      print '.'
    end
  end
end

puts
png.save(output)
