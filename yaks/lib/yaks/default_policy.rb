module Yaks
  class DefaultPolicy
    include Util

    # Default policy options.
    DEFAULTS = {
      rel_template: "rel:{rel}",
      namespace: Object
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
      return derive_mapper_from_collection(model) if model.respond_to? :to_ary
      derive_mapper_from_single_object(model)
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
    # This inspects the first element of the collection, so
    # it requires a collection with truthy elements. Will
    # return `nil` if the collection has no truthy elements.
    #
    # @param [#first] collection
    #
    # @return [String|nil]
    #
    # @raise [NameError]
    def derive_type_from_collection(collection)
      return if collection.none?
      derive_type_from_mapper_class(derive_mapper_from_object(collection.first))
    end

    def derive_mapper_from_association(association)
      @options[:namespace].const_get("#{camelize(association.singular_name)}Mapper")
    end

    # @param association [Yaks::Mapper::Association]
    # @return [String]
    def derive_rel_from_association(association)
      expand_rel(association.name)
    end

    # @param relname [String]
    # @return [String]
    def expand_rel(relname)
      URITemplate.new(@options[:rel_template]).expand(rel: relname)
    end

    private

    def derive_mapper_from_collection(collection)
      if m = collection.first
        name = "#{m.class.name.split('::').last}CollectionMapper"
        begin
          return @options[:namespace].const_get(name)
        rescue NameError               # rubocop:disable Lint/HandleExceptions
        end
      end
      begin
        return @options[:namespace].const_get(:CollectionMapper)
      rescue NameError                 # rubocop:disable Lint/HandleExceptions
      end
      CollectionMapper
    end

    def derive_mapper_from_single_object(model)
      klass = model.class
      splitted_class_name = klass.name.split("::")
      model_namespace = splitted_class_name[0...-1]
      model_class_name = splitted_class_name.last
      begin
        mapper_class_parts = [*model_namespace, "#{klass.name.split('::').last}Mapper"]
        return mapper_class_parts.inject(@options[:namespace]) do |prefix, suffix|
          prefix.const_get(suffix, false)
        end
      rescue NameError
        klass = klass.superclass
        unless model_namespace.empty? || klass
          model_namespace = []
          klass = model.class
        end
        retry if klass
      end
      raise "Failed to find a mapper for #{model.inspect}. Did you mean to implement #{model_class_name}Mapper?"
    end
  end
end
