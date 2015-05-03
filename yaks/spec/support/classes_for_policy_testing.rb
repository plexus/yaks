# Used by Yaks::DefaultPolicy* tests to test various name inference schemes

class SoyMapper; end
class Bean; end
class Soy < Bean; end
class Wheat; end

module MyMappers
  class SoyMapper; end
  class BeanMapper; end
end

class SoyCollectionMapper; end

module Namespace
  module Nested
    class Rye; end
    class Mung < Bean
      alias_method :inspect, :to_s # on 1.9 inspect calls to_s
      def to_s
        "mungbean"
      end
    end
  end

  class RyeMapper; end
  class RyeCollectionMapper; end

  class CollectionMapper; end

  class ShoeMapper; end
end

module DislikesCollectionMapper
  def self.const_get(const)
    raise "not a NameError" if const.to_s == 'CollectionMapper'
  end
end

module DislikesOtherMappers
  def self.const_get(const)
    raise "not a NameError" if const.to_s != 'CollectionMapper'
  end
end
