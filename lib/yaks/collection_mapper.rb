module Yaks
  class CollectionMapper
    CONFIG_METHOD=[:link]
    include Mapper::ClassMethods

    attr_reader :collection, :resource_mapper, :options
    private :collection, :resource_mapper, :options

    def initialize(collection, resource_mapper, options = {})
      @collection      = collection
      @resource_mapper = resource_mapper
      @options         = YAKS_DEFAULT_OPTIONS.merge(options)
    end

    def to_resource
      CollectionResource.new(nil, collection.map {|obj| resource_mapper.new(obj, options).to_resource})
    end
  end
end
