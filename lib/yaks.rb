require 'forwardable'

require 'hamster'
require 'concord'
require 'inflection'

module Yaks
  Undefined = Object.new

  module ClassMethods
    def default_serializer_lookup(obj = Undefined)
      return method(:default_serializer_lookup) if obj == Undefined
      Object.const_get("#{obj.class.name}Serializer")
    end

    def dump(objects, options = {})
      Yaks::Pipeline.new(objects, options).call
    end
  end
  extend ClassMethods

end

require 'yaks/util'
require 'yaks/serializable_collection'
require 'yaks/serializable_object'
require 'yaks/serializable_association'
require 'yaks/fold_json_api'
require 'yaks/fold_ams_compat'
require 'yaks/serializer/class_methods'
require 'yaks/serializer/lookup'
require 'yaks/serializer'
require 'yaks/collection_serializer'
require 'yaks/primitivize'
require 'yaks/pipeline'
