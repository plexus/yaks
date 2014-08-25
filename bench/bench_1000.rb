<<<<<<< HEAD
#!/usr/bin/env ruby

require 'benchmark/ips'
require 'yaks'
require 'ruby-prof'

SIZE=20
$timestamp = Time.now.utc.iso8601.gsub('-', '').gsub(':', '')
$yaks = Yaks.new

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


def profile!(name)
  RubyProf.start
  yield
  results = RubyProf.stop
  File.open "/tmp/#{name}-#{$timestamp}.out.#{$$}", 'w' do |file|
    RubyProf::CallTreePrinter.new(results).print(file)
  end
end

do_flat = ->(format) { -> { $yaks.serialize(flat, item_mapper: FlatMapper, format: format) } }
do_deep = ->(format) { -> { $yaks.serialize(deep, mapper: DeepMapper, format: format) } }

10.times { do_flat[:hal][] }
10.times { do_deep[:hal][] }

profile!('flat', &do_flat.(:hal))
profile!('deep', &do_deep.(:hal))
exit

Benchmark.ips(10) do |job|
  Yaks::Format.names.each do |format|

    job.report "#{format} ; #{SIZE} objects in a list ; no nesting", &do_flat.(format)
    job.report "#{format} ; #{SIZE} objects nested", &do_deep.(format)
  end
end
