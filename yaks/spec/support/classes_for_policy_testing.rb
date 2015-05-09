# Used by Yaks::DefaultPolicy* tests to test various name inference schemes

class SoyMapper; end
class Soy; end
class WildSoy < Soy; end

module Grain
  class Soy; end
  class WildSoy < Soy; end

  class Wheat; end
  class Durum < Wheat; end

  module Dry
    class Soy < ::Grain::Soy; end
    class SoyMapper; end
  end

  class SoyMapper; end
  class SoyCollectionMapper; end
end

class WheatMapper; end

module MyMappers
  class SoyMapper; end
  class WheatMapper; end

  module Grain
    class SoyMapper; end
  end
end

class SoyCollectionMapper; end

module Namespace
  module Nested
    class Rye; end
    class Mung
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
