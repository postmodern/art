#!/usr/bin/env ruby

# require 'chunky_png'
require 'oily_png'
require 'io/console'

unless ARGV.length == 2 || ARGV.length == 3
  $stderr.puts "usage: #{File.extname($0)} INPUT BG_COLOR [OUTPUT]"
  exit -1
end

input    = ARGV[0]
bg_color = ChunkyPNG::Color(ARGV[1])
output   = ARGV[2] || input
rows, columns = IO.console.winsize

png = ChunkyPNG::Image.from_file(input)

pixels_per_row    = png.height / rows
pixels_per_column = png.width / columns

png.height.times do |y|
  png.width.times do |x|
    pixel = png[x,y]
    alpha = ChunkyPNG::Color.a(pixel)

    if (alpha > 0) && (alpha < 255) # transparency detected
      png[x,y] = ChunkyPNG::Color.compose_precise(pixel,bg_color)
    end

    if (((y+1) % pixels_per_row) == 0) &&
       (((x+1) % pixels_per_column) == 0)
      print '.'
    end
  end
end

puts
png.save(output)
