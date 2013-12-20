module Yaks
  class Resource
    class Link
      include Concord.new(:rel, :uri)
    end
  end
end
