module Yaks

  # Define defaults for attribute-constructor based classes
  #
  # @example
  #
  #   class Foo
  #     include Anima.new(:foo, :bar),
  #             AttributeDefaults.new(foo: 3, :bar: 4)
  #   end
  #
  class AttributeDefaults < Module
    attr_reader :defaults

    def initialize(defaults)
      @defaults = defaults
    end

    def add(defaults)
      self.class.new(@defaults.merge(defaults))
    end

    def included(descendant)
      descendant.instance_exec(self) do |attribute_defaults|
        define_singleton_method(:attribute_defaults) { attribute_defaults }

        include InstanceMethods
      end
    end

    module InstanceMethods
      def initialize(attributes = {})
        super(self.class.attribute_defaults.defaults.merge(attributes))
      end
    end
  end
end
