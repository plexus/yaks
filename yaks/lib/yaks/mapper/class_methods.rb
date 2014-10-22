# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    module ClassMethods
      include Forwardable
      include Util
      include FP

      CONFIG_METHODS = [
        :type,
        :attributes,
        :link,
        :profile,
        :has_one,
        :has_many,
        :control
      ]

      def config
        @config ||= Config.new
        @config = yield(@config) if block_given?
        @config
      end

      def inherited(child)
        child.config { @config }
      end

      CONFIG_METHODS.each do |method_name|
        define_method method_name do |*args, &block|
          config &send_with_args(method_name, *args, &block)
        end
      end

    end
  end
end
