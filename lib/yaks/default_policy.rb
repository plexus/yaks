module Yaks
  class DefaultPolicy
    include Util

    DEFAULTS = {
      rel_template: "rel:src={mapper_name}&dest={association_name}",
      namespace: Kernel
    }

    attr_reader :options

    def initialize(options = {})
      @options = DEFAULTS.merge(options)
    end

    def derive_mapper_from_object(model)
      if model.respond_to? :to_ary
        if @options[:namespace].const_defined?(:CollectionMapper)
          @options[:namespace].const_get(:CollectionMapper)
        else
          Yaks::CollectionMapper
        end
      else
        name = model.class.name.split('::').last
        @options[:namespace].const_get(name + 'Mapper')
      end
    end

    def derive_type_from_mapper_class(mapper_class)
      underscore(mapper_class.to_s.sub(/Mapper$/, ''))
    end

    def derive_mapper_from_association(association)
      Object.const_get("#{camelize(singularize(association.name.to_s))}Mapper")
    end

    def derive_rel_from_association(mapper, association)
      URITemplate.new(@options[:rel_template]).expand(
        mapper_name: derive_type_from_mapper_class(mapper.class),
        association_name: association.name
      )
    end

  end
end
