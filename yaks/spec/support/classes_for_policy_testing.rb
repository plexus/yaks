# Used by Yaks::DefaultPolicy* tests to test various name inference schemes

class SoyMapper ; end
class Soy ; end
class Wheat ; end

module MyMappers
  class SoyMapper ; end
end

class SoyCollectionMapper ; end

module Namespace
  module Nested
    class Rye ; end
  end

  class RyeMapper ; end
  class RyeCollectionMapper ; end

  class CollectionMapper ; end

  class ShoeMapper ; end
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
