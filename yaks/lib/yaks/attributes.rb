module Yaks
  class Attributes < Module
    attr_reader :defaults, :names

    def initialize(*attrs)
      @defaults   = attrs.last.instance_of?(Hash) ? attrs.pop : {}
      @names = (attrs + @defaults.keys).uniq
    end

    def add(*attrs)
      defaults = attrs.last.instance_of?(Hash) ? attrs.pop : {}
      self.class.new(*[*(names+attrs), @defaults.merge(defaults)])
    end

    def included(descendant)
      descendant.module_exec(self) do |this|
        include InstanceMethods,
                Anima.new(*this.names),
                Anima::Update

        this.names.each do |attr|
          define_method attr do |value = Undefined|
            if value.equal? Undefined
              instance_variable_get("@#{attr}")
            else
              update(attr => value)
            end
          end
        end

        define_singleton_method(:attributes) { this }
      end
    end

    module InstanceMethods
      def initialize(attributes = {})
        super(self.class.attributes.defaults.merge(attributes))
      end

      def append_to(type, *objects)
        update(type => instance_variable_get("@#{type}") + objects)
      end

      def pp
        indent = ->(str) { str.lines.map {|l| "  #{l}"}.join }
        format = ->(val) { val.respond_to?(:pp) ? val.pp : val.inspect }

        fmt_attrs = self.class.attributes.attributes.map do |attr|
          value   = public_send(attr)
          fmt_val = case value
                    when Array
                      if value.inspect.length < 50
                        value.inspect
                      else
                        "[\n#{indent[value.map(&format).join(",\n")]}\n]"
                      end
                    else
                      format[value]
                    end
          "#{attr}: #{fmt_val}"
        end.join(",\n")

        "#{self.class.name}.new(\n#{indent[fmt_attrs]}\n)"
      end
    end
  end
end
