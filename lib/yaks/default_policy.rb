module Yaks
  class DefaultPolicy
    include Util

    # Default policy options.
    DEFAULTS = {
      rel_template: "rel:{rel}",
      namespace: Kernel
    }

    # @!attribute [r] options
    #   @return [Hash]
    attr_reader :options

    # @param [Hash] options
    # @return [Yaks::DefaultPolicy]
    def initialize(options = {})
      @options = DEFAULTS.merge(options)
    end

    # @param [Object] model
    # @return [Yaks::CollectionMapper, Yaks::Mapper]
    #   or a subclass of Yaks::Mapper of some sort.
    #
    # @raise [NameError] only occurs when the model
    #   is anything but a collection.
    #
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

    # @param [Class] mapper_class
    # @return [String]
    def derive_type_from_mapper_class(mapper_class)
      underscore(mapper_class.name.split('::').last.sub(/Mapper$/, ''))
    end

    # @param [Yaks::Mapper::Association] association
    # @return [Class] of subclass Yaks::Mapper
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

    # @param [Yaks::Mapper::Association] association
    # @return [String]
    def derive_rel_from_association(association)
      expand_rel( association.name )
    end

    # @param [String] relname
    # @return [String]
    def expand_rel(relname)
      URITemplate.new(@options[:rel_template]).expand(rel: relname)
    end
  end
end
