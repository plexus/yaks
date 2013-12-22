module Yaks
  class NullResource
    include Enumerable

    def each
      return to_enum unless block_given?
    end

    def attributes
      Yaks::Hash()
    end

    def links
      Yaks::List()
    end

    def subresources
      Yaks::Hash()
    end

    def [](*)
    end

    def collection?
      false
    end
  end
end
