require 'hexp'
require 'yaks'
require 'yaks/format/html'

-> do
  unparser = Hexp::Unparser.new({})
  Yaks::Serializer.register(:html, ->(data, env) { unparser.call(data) })
end.call
