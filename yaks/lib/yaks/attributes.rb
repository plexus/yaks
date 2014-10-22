module Yaks
  class Attributes < Module
    def initialize(*attrs)
      if attrs.last.is_a? Hash
        attrs_with_defaults = attrs.pop
        attrs = (attrs + attrs_with_defaults.keys).uniq
      end
      @modules = [
        Anima.new(*attrs),
        Anima::Update
      ]
      if attrs_with_defaults
        @modules << AttributeDefaults.new(attrs_with_defaults)
      end
    end

    def included(descendant)
      descendant.instance_exec(@modules) do |modules|
        include *modules

        anima.attributes.map(&:name).each do |attr|
          define_method attr do |value = Undefined|
            if value == Undefined
              instance_variable_get("@#{attr}")
            else
              update(attr => value)
            end
          end
        end
      end
    end
  end
end
