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
    def initialize(defaults)
      @defaults = defaults
    end

    def included(descendant)
      descendant.instance_exec(@defaults) do |defaults|
        define_singleton_method(:attribute_defaults) { defaults }
        prepend InstanceMethods
      end
    end

    module InstanceMethods
      def initialize(attributes = {})
        super(self.class.attribute_defaults.merge(attributes))
      end
    end
  end
end
