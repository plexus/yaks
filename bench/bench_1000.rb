#!/usr/bin/env ruby

require 'benchmark/ips'
require 'yaks'

# Flat: list of 1000 things

SIZE=20

FlatModel = Struct.new(:field1, :field2)
DeepModel = Struct.new(:field, :next)

flat = SIZE.times.map do |i|
  FlatModel.new(i, 'x' * (i % 50))
end

deep = nil
SIZE.times do |i|
  deep = DeepModel.new(i, deep)
end

class FlatMapper < Yaks::Mapper
  attributes :field1, :field2
  link :self, '/model/{field1}'
end

class DeepMapper < Yaks::Mapper
  attributes :field
  link :self, '/model/{field}'
  has_one :next, mapper: DeepMapper
end

Benchmark.ips(10) do |job|
  Yaks::Format.names.each do |format|

    $yaks = Yaks.new

    job.report "#{format} ; #{SIZE} objects in a list ; no nesting" do
      $yaks.serialize(flat, item_mapper: FlatMapper, format: format)
    end

    job.report "#{format} ; #{SIZE} objects nested" do
      $yaks.serialize(deep, mapper: DeepMapper, format: format)
    end
  end
end
