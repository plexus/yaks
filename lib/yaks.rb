# -*- coding: utf-8 -*-

require 'forwardable'

require 'hamster'
require 'concord'
require 'inflection'
require 'uri_template'

require 'yaks/util'
require 'yaks/cross_cutting'
require 'yaks/primitivize'

require 'yaks/profile_registry'
require 'yaks/default_policy'

module Yaks
  Undefined = Object.new

  YAKS_DEFAULT_OPTIONS = {
    policy: DefaultPolicy.new,
    profile_registry: NullProfileRegistry.new
  }

  module ClassMethods
    def Hash(object = nil)
      return object             if object.is_a? Hamster::Hash
      return Hamster::EmptyHash if object.nil?
      Hamster.hash(object)
    end

    def List(*entries)
      case entries.size
      when 0
        Hamster::EmptyList
      when 1
        if entries.first.respond_to? :to_list
          entries.first.to_list
        else
          Hamster.list(*entries.compact)
        end
      else
        Hamster.list(*entries)
      end
    end
  end
  extend ClassMethods

end

require 'yaks/resource/link_lookup'
require 'yaks/resource'
require 'yaks/resource/link'
require 'yaks/collection_resource'

require 'yaks/mapper/link'
require 'yaks/mapper/association'
require 'yaks/mapper/has_one'
require 'yaks/mapper/has_many'
require 'yaks/mapper/config'
require 'yaks/mapper/class_methods'
require 'yaks/mapper/shared_methods'
require 'yaks/mapper'
require 'yaks/collection_mapper'

require 'yaks/serializer'
require 'yaks/hal_serializer'
require 'yaks/json_api_serializer'
