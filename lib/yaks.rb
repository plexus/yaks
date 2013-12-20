# -*- coding: utf-8 -*-

require 'forwardable'

require 'hamster'
require 'concord'
require 'inflection'

module Yaks
  Undefined = Object.new

  module ClassMethods
    def Hash(object)
      return object if object.is_a? Hamster::Hash
      Hamster.hash(object)
    end

    def List(*entries)
      case entries.size
      when 0
        Hamster.list
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

require 'yaks/util'
require 'yaks/resource'
require 'yaks/mapper_config'
require 'yaks/mapper/class_methods'
require 'yaks/mapper'
