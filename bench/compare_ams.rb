# coding: utf-8

require 'pathname'

gem "active_model_serializers", "0.10.0.rc2"
gem "activerecord"
gem "yaks", path: Pathname(__FILE__).dirname.parent.join('yaks').to_s
gem "benchmark-ips"

module Rails
  class Railtie
    def self.initializer(*)
    end
  end
end

require "yaks"
require "active_record"
require "active_model_serializers"
require "benchmark/ips"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "bench.sqlite3")
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :first_name
    t.string :last_name
    t.string :email
    t.string :password
    t.date :date_of_birth
    t.timestamps null: false
  end
end

class User < ActiveRecord::Base
end

user = User.create(
  first_name: "Janko",
  last_name: "Marohnić",
  email: "janko.marohnic@gmail.com",
  password: "secret",
  date_of_birth: Date.new(1991, 3, 10),
)

class UserMapper < Yaks::Mapper
  attributes *User.column_names
end

class UserSerializer < ActiveModel::Serializer
  attributes *User.column_names
end

yaks = Yaks.new do
  default_format :json_api
  map_to_primitive Date, Time, &:iso8601
end

Benchmark.ips do |x|
  x.report("yaks") { yaks.call(user, mapper: UserMapper) }
  x.report("ams")  do
    serializer = UserSerializer.new(user)
    adapter = ActiveModel::Serializer::Adapter::JsonApi
    adapter.new(serializer).as_json
  end
  x.report("database") { User.all.to_a }
  x.compare!
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
