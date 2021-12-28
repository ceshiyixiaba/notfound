require 'zlib'

file = File.open('objects/pack/pack-164f4734388b5ebb26bf4607048798bec6ea6494.pack', 'rb')
file.seek(472+3)
zstream = Zlib::Inflate.new
buf = zstream.inflate(file.read)
puts zstream.total_out # 208
puts zstream.total_in  # 152
puts buf.bytes.map{|b| sprintf("%08b", b) }.join(' ')
zstream.finish
zstream.close
