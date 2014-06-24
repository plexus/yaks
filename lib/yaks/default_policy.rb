module Yaks
  class DefaultPolicy
    include Util

    DEFAULTS = {
      rel_template: "rel:src={src}&dest={dest}",
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
        Yaks::CollectionMapper
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

    def derive_rel_from_association(mapper, association)
      expand_rel( mapper.class.mapper_name(self), association.name )
    end

    def expand_rel(src_name, dest_name)
      URITemplate.new(@options[:rel_template]).expand(
        src: src_name,
        dest: dest_name
      )
    end
  end
end
