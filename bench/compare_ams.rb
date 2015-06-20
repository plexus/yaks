# coding: utf-8

require 'pathname'

gem "active_model_serializers", "0.10.0.rc2"
gem "activerecord", "4.2.2"
gem "benchmark-ips", "2.2.0"
gem "ruby-prof", "0.15.8"

module Rails
  class Railtie
    def self.initializer(*)
    end
  end
end

$:.unshift Pathname(__FILE__).dirname.parent.join('yaks/lib')

require "yaks"
require "active_record"
require "active_support"
require "active_model_serializers"
require "benchmark/ips"
require "pp"
require 'ruby-prof'

class User
  include Anima.new(:id, :first_name, :last_name, :email, :password, :date_of_birth)
  extend ActiveModel::Naming

  def read_attribute_for_serialization(x)
    to_h[x]
  end
end

user = User.new(
  id: 100,
  first_name: "Janko",
  last_name: "Marohnić",
  email: "janko.marohnic@gmail.com",
  password: "secret",
  date_of_birth: Date.new(1991, 3, 10),
)

class UserMapper < Yaks::Mapper
  attributes *User.anima.attributes.map(&:name)
end

class UserSerializer < ActiveModel::Serializer
  attributes *User.anima.attributes.map(&:name)
end

Timer = Hash.new do |hsh, key|
  hsh[key] = ->(val, env, &block) do
    start = Time.now
    GC.disable
    block.call(val, env).tap do
      hsh[:results][key] += Time.now - start
      GC.enable
    end
  end
end
Timer[:results] = Hash.new(0)


# RubyProf.start
# RubyProf.pause

yaks = Yaks.new do
  default_format :json_api
  map_to_primitive(Date, Time) {|x,e| x.iso8601 }

  around :map, &Timer[:map]
  around :format, &Timer[:format]
  # around :primitivize do |val, env, &block|
  #   RubyProf.resume
  #   result = block.call(val, env)
  #   RubyProf.pause
  #   result
  # end
  around :primitivize, &Timer[:primitivize]
  around :serialize, &Timer[:serialize]
end

Benchmark.ips do |x|
  x.report("yaks") { yaks.call(user, mapper: UserMapper) }
  x.report("ams")  do
    serializer = UserSerializer.new(user)
    adapter = ActiveModel::Serializer::Adapter::JsonApi
    adapter.new(serializer).as_json
  end
  x.compare!
end

Timer[:results] = Hash.new(0)

5000.times do
  yaks.call(user, mapper: UserMapper)
end

pp Timer[:results]

def make_timestamp
  Time.now.utc.iso8601.gsub('-', '').gsub(':', '')
end

RubyProf.start
yaks.call(user, mapper: UserMapper)
results = RubyProf.stop
File.open "/tmp/yaks-#{make_timestamp}.out.#{$$}", 'w' do |file|
  RubyProf::CallTreePrinter.new(results).print(file)
end

# -- create_table(:users, {:force=>true})
#    -> 0.0109s
# Calculating -------------------------------------
#                 yaks   234.000  i/100ms
#                  ams     2.442k i/100ms
#             database   465.000  i/100ms
# -------------------------------------------------
#                 yaks      2.387k (± 3.0%) i/s -     11.934k
#                  ams     29.942k (± 2.5%) i/s -    151.404k
#             database      5.005k (± 1.6%) i/s -     25.110k

# Comparison:
#                  ams:    29941.7 i/s
#             database:     5004.9 i/s - 5.98x slower
#                 yaks:     2386.8 i/s - 12.54x slower
