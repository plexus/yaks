module Yaks
  class Mapper
    class Form
      class Legend
        include Attributes.new(:type, :label, if: nil)

        def self.create(label, opts = {})
          new(opts.merge(type: :legend, label: label))
        end

        def to_resource_fields(mapper)
          return [] if self.if && !mapper.expand_value(self.if)
          [ Yaks::Resource::Form::Legend.new(label: mapper.expand_value(label)) ]
        end
      end
    end
  end
end
