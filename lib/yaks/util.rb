# -*- coding: utf-8 -*-
module Yaks
  module Util
    extend self
    extend Forwardable

    def_delegators Inflection, :singular, :singularize, :pluralize

    def underscore(str)
      str.gsub(/::/, '/')
        .gsub(/(?<!^|\/)([A-Z])(?=[a-z$])|(?<=[a-z])([A-Z])/, '_\1\2')
        .tr("-", "_")
        .downcase!
    end

    def camelize(str)
      str.gsub(/\/(.?)/)     { "::#{ $1.upcase }" }
        .gsub!(/(?:^|_)(.)/) { $1.upcase          }
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

    def curry_method(name)
      method(name).to_proc.curry
    end
    alias λ curry_method
    alias hakell curry_method
    alias schönefinkel curry_method

  end
end
