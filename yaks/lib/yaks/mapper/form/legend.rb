module Yaks
  class Mapper
    class Form
      class Legend
        include Attribs.new(:type, :label, if: nil)

        def self.create(label, opts = {})
          new(opts.merge(type: :legend, label: label))
        end

        def to_resource_fields(mapper)
          return [] unless self.if.nil? || mapper.expand_value(self.if)
          [ Resource::Form::Legend.new(label: mapper.expand_value(label)) ]
        end
      end
    end
  end
end
