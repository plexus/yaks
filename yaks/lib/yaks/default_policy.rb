module Yaks
  class DefaultPolicy
    include Util

    # Default policy options.
    DEFAULTS = {
      rel_template: "rel:{rel}",
      namespace: Kernel
    }

    # @!attribute [r]
    #   @return [Hash]
    attr_reader :options

    # @param options [Hash] options
    def initialize(options = {})
      @options = DEFAULTS.merge(options)
    end

    # @param model [Object]
    # @return [Class] A mapper, typically a subclass of Yaks::Mapper
    #
    # @raise [NameError] only occurs when the model is anything but a collection.
    def derive_mapper_from_object(model)
      if model.respond_to? :to_ary
        if m = model.first
          name = m.class.name.split('::').last + 'CollectionMapper'
          begin
            return @options[:namespace].const_get(name)
          rescue NameError
          end
        end
        begin
          return @options[:namespace].const_get(:CollectionMapper)
        rescue NameError
        end
        CollectionMapper
      else
        name = model.class.name.split('::').last
        @options[:namespace].const_get(name + 'Mapper')
      end
    end

    # Derive the a mapper type name
    #
    # This returns the 'system name' for a mapper,
    # e.g. ShowEventMapper => show_event.
    #
    # @param [Class]  mapper_class
    #
    # @return [String]
    def derive_type_from_mapper_class(mapper_class)
      underscore(mapper_class.name.split('::').last.sub(/Mapper$/, ''))
    end

    # Derive the mapper type name from a collection
    #
    # This inspects the first element of the collection, so it
    # requires a non-empty collection. Will return nil if the
    # collection is empty.
    #
    # @param [#first] collection
    #
    # @return [String|nil]
    #
    # @raise [NameError]
    def derive_type_from_collection(collection)
      if collection.any?
        derive_type_from_mapper_class(
          derive_mapper_from_object(collection.first)
        )
      end
    end

    def derive_mapper_from_association(association)
      @options[:namespace].const_get("#{camelize(association.singular_name)}Mapper")
    end

    # @param association [Yaks::Mapper::Association]
    # @return [String]
    def derive_rel_from_association(association)
      expand_rel( association.name )
    end

    # @param relname [String]
    # @return [String]
    def expand_rel(relname)
      URITemplate.new(@options[:rel_template]).expand(rel: relname)
    end

  end
end
