module Yaks
  class DefaultPolicy
    include Util

    def derive_mapper_from_association(association)
      Object.const_get("#{camelize(association.name.to_s)}Mapper")
    end

    def derive_rel_from_association(mapper, association)
      mapper_name = underscore(mapper.class.name.sub(/Mapper$/, ''))
      "rel:src=#{mapper_name}&dest=#{association.key}"
    end

  end
end
