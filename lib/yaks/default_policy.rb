module Yaks
  class DefaultPolicy
    include Util

    def derive_mapper_from_model(model)
      Kernel.const_get(model.class.name + 'Mapper')
    end

    def derive_key_from_mapper(mapper)
      underscore(mapper.class.name.sub(/Mapper$/, ''))
    end

    def derive_mapper_from_association(association)
      Object.const_get("#{camelize(singularize(association.name.to_s))}Mapper")
    end

    def derive_rel_from_association(mapper, association)
      mapper_name = derive_key_from_mapper(mapper)
      "rel:src=#{mapper_name}&dest=#{association.name}"
    end

  end
end
