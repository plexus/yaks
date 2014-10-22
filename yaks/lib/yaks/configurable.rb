module Yaks
  module Configurable
    def self.included(descendant)
      descendant.instance_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def config_method(name, options)
        define_method name do |*args, &block|
          append_to(
            options.fetch(:append_to),
            options.fetch(:create).create(*args, &block)
          )
        end
      end
    end

    def append_to(type, *objects)
      update(type => instance_variable_get("@#{type}") + objects)
    end
  end
end
