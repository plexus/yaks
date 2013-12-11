require 'forwardable'

require 'hamster'
require 'concord'
require 'inflection'

module Yaks
  Undefined = Object.new

  class << self
    def default_serializer_lookup(obj = Undefined)
      return method(:default_serializer_lookup) if obj == Undefined
      if obj.respond_to?(:to_str)
        Object.const_get("#{Util.singular(Util.camelize(obj.to_str))}Serializer")
      else
        Object.const_get("#{obj.class.name}Serializer")
      end
    end
  end

  def List(*args)
    Hamster.list(*args)
  end

  def Hash(*args)
    Hamster.hash(*args)
  end

  def Set(*args)
    Hamster.set(*args)
  end
end

require 'yaks/util'
require 'yaks/serializable_collection'
require 'yaks/serializable_object'
require 'yaks/serializable_association'
require 'yaks/fold_json_api'
require 'yaks/fold_ams_compat'
require 'yaks/serializer/class_methods'
require 'yaks/serializer'
require 'yaks/primitivize'
require 'yaks/dumper'
