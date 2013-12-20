module Yaks
  class Resource
    attr_reader :attributes

    def initialize(attributes)
      @attributes = Yaks::Hash(attributes)
    end
  end
end
