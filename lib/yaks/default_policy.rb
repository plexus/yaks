module Yaks
  class DefaultPolicy
    include Util

    def derive_profile_from_mapper(mapper)
      underscore(mapper.class.name.sub(/Mapper$/, '')).to_sym
    end

    def derive_missing_mapper_for_association(association)
      Object.const_get("#{camelize(association.name.to_s)}Mapper")
    end
  end
end
