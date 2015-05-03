require 'hexp'
require 'yaks'
require 'yaks/format/html'

-> do
  unparser = Hexp::Unparser.new({no_escape: [:script, :style]})
  Yaks::Serializer.register(:html, ->(data, _env) { unparser.call(data) })
end.call
