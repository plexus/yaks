module Yaks
  class DefaultPolicy
    include Util

    DEFAULTS = {
      rel_template: "rel:{rel}",
      namespace: Kernel
    }

    attr_reader :options

    def initialize(options = {})
      @options = DEFAULTS.merge(options)
    end

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

    def derive_type_from_mapper_class(mapper_class)
      underscore(mapper_class.name.split('::').last.sub(/Mapper$/, ''))
    end

    def derive_mapper_from_association(association)
      @options[:namespace].const_get("#{camelize(association.singular_name)}Mapper")
    end

    def derive_rel_from_association(association)
      expand_rel( association.name )
    end

    def expand_rel(relname)
      URITemplate.new(@options[:rel_template]).expand(rel: relname)
    end
  end
end
