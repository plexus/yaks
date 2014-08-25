require 'benchmark/ips'
require 'yaks'

# Flat: list of 1000 things

Model = Struct.new(:field1, :field2)

models = 1000.times.map do |i|
  Model.new(i, 'x' * (i % 50))
end

class Mapper < Yaks::Mapper
  attributes :field1, :field2
  link :self, '/model/{field1}'
end


Benchmark.ips do |x|
  Yaks::Format.names.each do |format|

    $yaks = Yaks.new

    x.report "#{format} ; 1000 objects in a list ; no nesting" do
      $yaks.serialize(models, item_mapper: Mapper, format: format)
    end
  end
end
