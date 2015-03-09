module Yaks
  class Mapper
    class Form
      class Fieldset
        extend Forwardable
        include Concord.new(:config)

        def_delegators :config, :fields, :dynamic_blocks

        ConfigBuilder = Builder.new(Config) do
          def_add :field, create: Field::Builder, append_to: :fields
          def_add :fieldset, create: Fieldset, append_to: :fields
          HTML5Forms::INPUT_TYPES.each do |type|
            def_add(type,
              create: Field::Builder,
              append_to: :fields,
              defaults: { type: type }
            )
          end
          def_forward :dynamic
        end

        def self.create(_opts = nil, &block)
          new(ConfigBuilder.build(Config.new, &block))
        end

        def to_resource(mapper)
          config = dynamic_blocks.inject(config()) do |config, block|
            ConfigBuilder.build(config, mapper.object, &block)
          end

          resource_fields = resource_fields(config.fields, mapper)

          Resource::Form::Fieldset.new(fields: resource_fields)
        end

        def resource_fields(fields, mapper)
          fields.map { |field| field.to_resource(mapper) }
        end
      end
    end
  end
end
