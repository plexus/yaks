module Yaks
  class Mapper
    class Form
      class Config
        include Attribs.new(
                  name: nil,
                  action: nil,
                  title: nil,
                  method: nil,
                  media_type: nil,
                  fields: [],
                  if: nil
                )

        Builder = Yaks::Builder.new(self) do
          def_set :action, :title, :method, :media_type
          def_add :field, create: Field::Builder, append_to: :fields
          def_add :fieldset, create: Fieldset, append_to: :fields
          HTML5Forms::INPUT_TYPES.each do |type|
            def_add(type,
                    create: Field::Builder,
                    append_to: :fields,
                    defaults: { type: type })
          end
          def_add :legend, create: Legend, append_to: :fields
          def_add :dynamic, create: DynamicField, append_to: :fields
          def_forward :condition
        end

        # Builder expects a `create' method. Alias to constructor
        def self.create(options)
          new(options)
        end

        # Build up a configuration based on an initial set of
        # attributes, and a configuration block
        def self.build(options = {}, &block)
          Builder.create(options, &block)
        end

        # Build up a configuration based on a config block. Provide an
        # object to be supplied to the block
        def self.build_with_object(object, &block)
          Builder.build(new, object, &block)
        end

        def condition(prc = nil, &blk)
          with(if: prc || blk)
        end

        def to_resource_fields(mapper)
          fields.flat_map do |field|
            field.to_resource_fields(mapper)
          end
        end
      end
    end
  end
end
