#!/usr/bin/env ruby

# require 'chunky_png'
require 'oily_png'
require 'io/console'

unless (ARGV.length == 2 || ARGV.length == 3)
  $stderr.puts "usage: #{File.extname($0)} INPUT OFFSET [OUTPUT]"
  exit -1
end

input  = ARGV[0]
offset = ARGV[1].to_i
output = ARGV[2] || input
rows, columns = IO.console.winsize

ALPHA = 128
OPACITY_MASK = ChukyPNG::Color::BLACK

input_png  = ChunkyPNG::Image.from_file(input)
cyan_image  = ChunkyPNG::Image.new(
  input_png.width, input_png.height, ChunkyPNG::Color::TRANSPARENT
)
red_image  = ChunkyPNG::Image.new(
  input_png.width, input_png.height, ChunkyPNG::Color::TRANSPARENT
)

pixels_per_row    = input_png.height / rows
pixels_per_column = input_png.width / columns

puts "Splitting image into Cyan and Red images ..."

input_png.height.times do |y|
  input_png.width.times do |x|
    pixel = input_png[x,y]

    unless ChunkyPNG::Color.a(pixel) == 0
      bw   = ChunkyPNG::Color.grayscale(ChunkyPNG::Color.grayscale_teint(pixel))
      cyan = ChunkyPNG::Color.rgba(
        0, ChunkyPNG::Color.g(bw), ChunkyPNG::Color.b(bw), ALPHA
      )
      red = ChunkyPNG::Color.rgba(
        ChunkyPNG::Color.r(bw), 0, 0, ALPHA
      )

      if x >= offset
        cyan_image[x - offset, y] = cyan
      end

      if x < (red_image.width - offset)
        red_image[x + offset, y] = red
      end
    end
  end
end

puts "Merging Cyan and Red images ..."

output_png = ChunkyPNG::Image.new(
  input_png.width, input_png.height, ChunkyPNG::Color::TRANSPARENT
)

def screen(i,m)
  # https://docs.gimp.org/en/gimp-concepts-layer-modes.html
  255 - (((255 - m) * (255 - i)) / 255.0).to_i
end

def screen_color(c1,c2)
  ChunkyPNG::Color.rgba(
    screen(ChunkyPNG::Color.r(c1), ChunkyPNG::Color.r(c2)),
    screen(ChunkyPNG::Color.g(c1), ChunkyPNG::Color.g(c2)),
    screen(ChunkyPNG::Color.b(c1), ChunkyPNG::Color.b(c2)),
    screen(ChunkyPNG::Color.a(c1), ChunkyPNG::Color.a(c2)),
  )
end

input_png.height.times do |y|
  input_png.width.times do |x|
    red_pixel  = red_image[x,y]
    cyan_pixel = cyan_image[x,y]

    next if ChunkyPNG::Color.a(red_pixel) == 0 &&
            ChunkyPNG::Color.a(cyan_pixel) == 0

    output_png[x,y] = screen_color(
      screen_color(red_pixel, cyan_pixel),
      OPACITY_MASK
    )
  end
end

output_png.save(output)
