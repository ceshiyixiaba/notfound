#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require 'stringio'
require 'zlib'

def get_delta_hdr_size(io)
  cmd = size = i = 0
  loop do
    cmd = io.getbyte
    size |= ((cmd & 0x7F) << i)
    i += 7
    break if (cmd & 0x80) != 0x80 || io.eof?
  end
  size
end

def parse_cp_param(io, cmd, bit, var, shift)
  return var if (cmd & bit).zero?

  var | (io.getbyte << shift)
end

def patch_delta(data, object)
  io = StringIO.new(data)

  get_delta_hdr_size(io)
  get_delta_hdr_size(io)

  object[:delta] = []
  loop do
    cmd = io.getbyte
    break if io.eof?

    cp_off = cp_size = 0
    cp_off = parse_cp_param(io, cmd, 0x01, cp_off, 0)
    cp_off = parse_cp_param(io, cmd, 0x02, cp_off, 8)
    cp_off = parse_cp_param(io, cmd, 0x04, cp_off, 16)
    cp_off = parse_cp_param(io, cmd, 0x08, cp_off, 24)
    cp_size = parse_cp_param(io, cmd, 0x10, cp_size, 0)
    cp_size = parse_cp_param(io, cmd, 0x20, cp_size, 8)
    cp_size = parse_cp_param(io, cmd, 0x40, cp_size, 16)

    object[:delta] << {
      cp_off: cp_off,
      cp_size: cp_size
    }
  end
end

PACK_PATH = Dir.glob('git-pack-format.git/objects/pack/pack-*.pack').first
puts PACK_PATH

CMD = %W[git index-pack --verify-stat #{PACK_PATH}].freeze
IO.popen(CMD) do |f|
  puts f.readlines
end

TYPE = %i[invalid commit tree blob tag reserved ofs_delta ref_delta].freeze

file = File.open(PACK_PATH, 'rb')

result = {}
result[:signature] = file.read(4)
result[:version] = file.read(4).unpack1('N')
result[:object_count] = file.read(4).unpack1('N')
result[:objects] = []

result[:object_count].times do
  object = { offset: file.tell }

  byte = file.readbyte
  size = (byte & 0x0F)
  object[:type] = TYPE[(byte & 0x70) >> 4]

  offset = 4
  while byte & 0x80 == 0x80
    byte = file.readbyte
    size = ((byte & 0x7F) << offset) + size
    offset = 7
  end
  object[:size] = size

  if object[:type] == :ofs_delta
    c = file.readbyte
    base_offset = c & 127
    while (c & 0x80) == 0x80
      base_offset += 1
      c = file.readbyte
      base_offset = (base_offset << 7) + (c & 0x7F)
    end
    object[:ofs_offset] = object[:offset] - base_offset
  end

  cpos = file.tell

  zi = Zlib::Inflate.new
  zi.avail_out = size
  data = zi.inflate(file.read)
  object[:data] = data
  object[:oid] = Digest::SHA1.hexdigest("#{object[:type]} #{size}\0".b + data)
  object[:size_in_packfile] = zi.total_in + (cpos - object[:offset])
  result[:objects] << object

  file.seek(cpos + zi.total_in)

  if object[:type] == :ofs_delta
    patch_delta(data, object)
    base_data = result[:objects].find { |o| o[:offset] == object[:ofs_offset] }[:data]
    object[:data] = "".b
    object[:delta].each do |pair|
      cp_off = pair[:cp_off]
      cp_size = pair[:cp_size]
      object[:data] << base_data[cp_off, cp_size]
    end
    puts object[:data]
    object[:oid] = Digest::SHA1.hexdigest("blob #{object[:data].size}\0".b + object[:data])
  end
  zi.finish
  zi.close
ensure
  puts object
end

file.close
