module Yaks
  class Serializer
    extend Forwardable

    attr_reader :resource, :options
    def_delegators :resource, :links, :attributes, :subresources

    protected :resource, :links, :attributes, :subresources, :options

    def initialize(resource, options = {})
      @resource = resource
      @options  = {}.merge(options)
    end

  end
end
