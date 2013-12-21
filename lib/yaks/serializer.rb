module Yaks
  class Serializer
    attr_reader :resource
    private :resource

    def initialize(resource)
      @resource = resource
    end
  end
end
