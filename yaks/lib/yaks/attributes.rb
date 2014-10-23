module Yaks
  class Attributes < Module
    def initialize(*attrs)
      @defaults   = attrs.last.is_a?(Hash) ? attrs.pop : {}
      @attributes = (attrs + @defaults.keys).uniq
      define_attr_methods
    end

    def add(*attrs)
      defaults = attrs.last.is_a?(Hash) ? attrs.pop : {}
      self.class.new(*[*attrs, @defaults.merge(defaults)])
    end

    def define_attr_methods
      @attributes.each do |attr|
        define_method attr do |value = Undefined|
          if value.equal? Undefined
            instance_variable_get("@#{attr}")
          else
            update(attr => value)
          end
        end
      end
    end

    def included(descendant)
      descendant.module_exec(self, @attributes, @defaults) do |this, attributes, defaults|
        include InstanceMethods,
                Anima.new(*attributes),
                Anima::Update

        define_singleton_method(:attributes)         { this }
        define_singleton_method(:attribute_defaults) { defaults }
      end
    end

    module InstanceMethods
      def initialize(attributes = {})
        super(self.class.attribute_defaults.merge(attributes))
      end

      def append_to(type, *objects)
        update(type => instance_variable_get("@#{type}") + objects)
      end
    end
  end
end
