# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    module ClassMethods
      extend Util::Deprecated
      include Forwardable,
              Util,
              FP

      def config(value = Undefined)
        if value.equal? Undefined
          @config
        else
          raise if value.nil?
          @config = value
        end
      end

      def inherited(child)
        child.config(config)
      end

      CONFIG_METHODS = [
        :type,
        :attributes,
        :link,
        :profile,
        :has_one,
        :has_many,
        :form
      ]

      CONFIG_METHODS.each do |method_name|
        define_method method_name do |*args, &block|
          if args.empty?
            config.public_send(method_name, *args, &block)
          else
            config(config.public_send(method_name, *args, &block))
          end
        end
      end

      deprecated_alias :control, :form
    end
  end
end
