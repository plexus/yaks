module Yaks
  class DefaultPolicy
    include Util

    def derive_profile_from_mapper(mapper)
      underscore(mapper.class.name.sub(/Mapper$/, '')).to_sym
    end
  end
end
