require 'hexp'
require 'yaks'
require 'yaks/format/html'

Yaks::Serializer.register(:html, Hexp::Unparser.new({}))
