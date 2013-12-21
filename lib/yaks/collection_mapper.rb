# -*- coding: utf-8 -*-
module Yaks
  class CollectionMapper
    include Util, Mapper::MapLinks, CrossCutting
    extend Mapper::ClassMethods

    attr_reader :collection, :resource_mapper, :options
    private :collection, :resource_mapper, :options

    def_delegators 'self.class', :config
    def_delegators :config, :links

    def initialize(collection, resource_mapper, options = {})
      @collection      = collection
      @resource_mapper = resource_mapper
      @options         = YAKS_DEFAULT_OPTIONS.merge(options)
    end

    def to_resource
      CollectionResource.new(map_links, collection.map {|obj| resource_mapper.new(obj, options).to_resource})
    end

    def load_attribute(name)
      respond_to?(name) ? send(name) : collection.map(&name.to_sym)
    end

    def profile_type
      resource_mapper.new(nil, options).profile_type
    end

  end
end
