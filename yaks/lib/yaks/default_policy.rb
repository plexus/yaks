
module Yaks
  class DefaultPolicy
    include Util

    # Default policy options.
    DEFAULTS = {
      rel_template: "rel:{rel}",
      namespace: Object,
      mapper_rules: {}
    }

    # @!attribute [r]
    #   @return [Hash]
    attr_reader :options

    # @param options [Hash] options
    def initialize(options = {})
      @options = DEFAULTS.merge(options)
    end

    # Main point of entry for mapper derivation. Calls
    # derive_mapper_from_collection or derive_mapper_from_item
    # depending on the model.
    #
    # @param model [Object]
    # @return [Class] A mapper, typically a subclass of Yaks::Mapper
    #
    # @raise [RuntimeError] occurs when no mapper is found
    def derive_mapper_from_object(model)
      mapper = detect_configured_mapper_for(model)
      return mapper if mapper
      return derive_mapper_from_collection(model) if model.respond_to? :to_ary
      derive_mapper_from_item(model)
    end

    # Derives a mapper from the given collection.
    #
    # @param collection [Object]
    # @return [Class] A mapper, typically a subclass of Yaks::Mapper
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

    # Derives a mapper from the given item. This item should not
    # be a collection.
    #
    # @param item [Object]
    # @return [Class] A mapper, typically a subclass of Yaks::Mapper
    #
    # @raise [RuntimeError] only occurs when no mapper is found for the given item.
    def derive_mapper_from_item(item)
      klass = item.class
      splitted_class_name = klass.name.split("::")
      item_namespace = splitted_class_name[0...-1]
      item_class_name = splitted_class_name.last
      begin
        mapper_class_parts = [*item_namespace, "#{klass.name.split('::').last}Mapper"]
        return mapper_class_parts.inject(@options[:namespace]) do |prefix, suffix|
          prefix.const_get(suffix, false)
        end
      rescue NameError
        klass = klass.superclass
        unless item_namespace.empty? || klass
          item_namespace = []
          klass = item.class
        end
        retry if klass
      end
      raise "Failed to find a mapper for #{item.inspect}. Did you mean to implement #{item_class_name}Mapper?"
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

    def detect_configured_mapper_for(object)
      @options[:mapper_rules].each do |rule, mapper_class|
        return mapper_class if rule === object # rubocop:disable Style/CaseEquality
      end
      nil
    end
  end
end
