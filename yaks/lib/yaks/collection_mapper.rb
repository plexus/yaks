module Yaks
  class CollectionMapper < Mapper
    alias_method :collection, :object

    # @param [Array] collection
    # @return [Array]
    def call(collection, _env = nil)
      @object = collection

      attrs = {
        type: collection_type,
        members: collection().map do |obj|
          mapper_for_model(obj).new(context).call(obj)
        end
      }

      # For collections from associations the rel will be based on the
      # association. At the top level there's no association, so we
      # use a generic rel. This matters especially for HAL, where a
      # top-level collection is rendered as an object with the
      # collection as a subresource.
      if context[:mapper_stack].empty?
        attrs[:rels] = [collection_rel]
      end

      map_attributes(
        map_links(
          CollectionResource.new(attrs)
        )
      )
    end

    private

    def collection_rel
      if collection_type
        policy.expand_rel( pluralize( collection_type ) )
      else
        'collection'
      end
    end

    def collection_type
      if item_mapper = context[:item_mapper]
        item_mapper.config.type || policy.derive_type_from_mapper_class(item_mapper)
      else
        policy.derive_type_from_collection(collection)
      end
    end

    def mapper_for_model(model)
      context.fetch(:item_mapper) do
        policy.derive_mapper_from_object(model)
      end
    end
  end
end
