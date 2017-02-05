#!/usr/bin/env ruby

require 'rqrcode_png'

unless ARGV.length == 3
  $stderr.puts "usage: #{File.basename($0)} URL OUTPUT SIZE"
  exit -1
end

url = ARGV[0]
output = ARGV[1]
size   = ARGV[2].to_i

qr = RQRCode::QRCode.new(url, level: :h)
png = qr.to_img
png.resize(size, size).save(output)
