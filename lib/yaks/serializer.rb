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

    def profile_name
      (profile = resource.profile) &&
        profile_registry.find_by_uri(profile)
    end

  end
end
