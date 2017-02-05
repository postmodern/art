#!/usr/bin/env ruby

require 'rqrcode_png'

DPI = 150
DIM = DPI * 3

unless ARGV.length == 2
  $stderr.puts "usage: #{File.basename($0)} URL OUTPUT"
  exit -1
end

url = ARGV[0]
output = ARGV[1]

qr = RQRCode::QRCode.new(url, level: :h)
png = qr.to_img
png.resize(DIM, DIM).save(output)
