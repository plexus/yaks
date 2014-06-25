module Yaks
  class Mapper
    class AssociationMapper
      attr_reader :parent_mapper, :context, :rel, :association

      def initialize(parent_mapper, association, context)
        @parent_mapper = parent_mapper
        @association   = association
        @context       = context.merge(
          mapper_stack: context[:mapper_stack] + [parent_mapper]
        )
        @rel           = association.map_rel(parent_mapper, policy)
      end

      def policy
        context.fetch(:policy)
      end

      def call(resource)
        if association.render_as_link?(parent_mapper)
          add_link(resource)
        else
          add_subresource(resource)
        end
      end

      def add_link(resource)
        Link.new(rel, association.href, {})
          .add_to_resource(resource, parent_mapper, nil)
        # Yaks::Mapper::Link doesn't do anything with the context, making it
        # hard to test that we pass it a context. Passing nil for now, until
        # this is actually needed and can be tested.
      end

      def add_subresource(resource)
        object      = parent_mapper.load_association(association.name)
        subresource = association.map_resource(object, context)
        resource.add_subresource(rel, subresource)
      end
    end
  end
end
