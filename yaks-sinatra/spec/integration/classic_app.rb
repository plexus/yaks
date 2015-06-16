require 'sinatra'
require 'yaks-sinatra'

Root = Class.new(Struct.new(:name))

class RootMapper < Yaks::Mapper
  link :self, '/'
end

set :default_charset, 'utf-8'

configure_yaks

get '/' do
  yaks Root.new('root'), mapper: RootMapper
end
