# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    module ClassMethods
      include Forwardable
      include Util

      CONFIG_METHODS = [
        :attributes,
        # :link,
        # :profile,
        # :embed,
        # :has_one,
        # :has_many
      ]

      def __mapper_config
        @__mapper_config ||= MapperConfig.new
        @__mapper_config = yield(@__mapper_config) if block_given?
        @__mapper_config
      end

      def inherited(child)
        child.__mapper_config { @__mapper_config }
      end

      CONFIG_METHODS.each do |method_name|
        define_method method_name do |*args|
          __mapper_config &σ(method_name, *args)
        end
      end

    end
  end
end
