module Yaks
  class Mapper
    class Form
      class Fieldset
        extend Forwardable
        include Attribs.new(:config)

        def_delegators :config, :fields

        def self.create(options = {}, &block)
          new(config: Config.build(options, &block))
        end

        def to_resource_fields(mapper)
          return [] if config.if && !mapper.expand_value(config.if)
          [ Resource::Form::Fieldset.new(fields: config.to_resource_fields(mapper)) ]
        end
      end
    end
  end
end
