module Yaks
  class Mapper
    class Association
      include Attribs.new(
                name:        Undefined,
                item_mapper: Undefined,
                rel:         Undefined,
                href:        Undefined,
                link_if:     Undefined,
                if:          Undefined
              ),
              Util,
              AbstractType

      def self.create(name, options = {})
        if options.key?(:mapper)
          options = options.dup
          mapper  = options.delete(:mapper)
          options[:item_mapper] = mapper
        end
        options[:name] = name
        new(options)
      end

      def add_to_resource(resource, parent_mapper, context)
        return resource unless parent_mapper.expand_value(self.if)
        AssociationMapper.new(parent_mapper, self, context).call(resource)
      end

      def render_as_link?(parent_mapper)
        href != Undefined && link_if != Undefined && Resolve(link_if, parent_mapper)
      end

      def map_rel(policy)
        return rel unless rel.equal?(Undefined)
        policy.derive_rel_from_association(self)
      end

      # @param object
      # @param context
      abstract_method :map_resource

      # support for HasOne and HasMany
      def resolve_association_mapper(policy)
        return item_mapper unless item_mapper.equal?(Undefined)
        policy.derive_mapper_from_association(self)
      end

    end
  end
end
