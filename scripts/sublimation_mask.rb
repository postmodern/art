#!/usr/bin/env ruby

# require 'chunky_png'
require 'oily_png'
require 'io/console'

unless ARGV.length == 2 || ARGV.length == 3
  $stderr.puts "usage: #{File.basename($0)} INPUT MASK [OUTPUT]"
end

input  = ARGV[0]
mask   = ARGV[1]
output = ARGV[2] || input
rows, columns = IO.console.winsize

mask_png = ChunkyPNG::Image.from_file(mask)
input_png = ChunkyPNG::Image.from_file(input)

unless (input_png.height == mask_png.height) &&
       (input_png.width  == mask_png.width)
  $stderr.puts "error: input image must be the same dimensions as mask image!"
  $stderr.puts "\tinput: #{input_png.width}x#{input_png.height}"
  $stderr.puts "\tmask: #{mask_png.width}x#{mask_png.height}"
  exit -1
end

pixels_per_row    = mask_png.height / rows
pixels_per_column = mask_png.width / columns

mask_png.height.times do |y|
  mask_png.width.times do |x|
    if mask_png[x,y] != ChunkyPNG::Color::TRANSPARENT
      input_png[x,y] = ChunkyPNG::Color::TRANSPARENT
      masked = true
    else
      masked = false
    end

    if (((y+1) % pixels_per_row) == 0) &&
       (((x+1) % pixels_per_column) == 0)
      if masked then  print ' '
      else            print '.'
      end
    end
  end
end

puts
input_png.save(output)
