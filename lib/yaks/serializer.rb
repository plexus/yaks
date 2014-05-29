module Yaks
  class Serializer
    extend Forwardable
    include Util

    attr_reader :resource, :options
    def_delegators :resource, :links, :attributes, :subresources

    protected :resource, :links, :attributes, :subresources, :options

    def initialize(resource, options = {})
      @resource = resource
      @options  = YAKS_DEFAULT_OPTIONS.merge(options)
    end

    def call
      serialize_resource(resource)
    end
    alias serialize call

  end
end
