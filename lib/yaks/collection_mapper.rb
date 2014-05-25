# -*- coding: utf-8 -*-

module Yaks
  class CollectionMapper
    include Util, FP
    extend Mapper::ClassMethods

    attr_reader :collection, :resource_mapper, :policy
    private :collection, :resource_mapper

    def_delegators 'self.class', :config
    def_delegators :config, :links

    def initialize(collection, resource_mapper, policy)
      @collection      = collection
      @resource_mapper = resource_mapper
      @policy          = policy
    end

    def to_resource
      CollectionResource.new(
        type: resource_mapper.config.type || policy.derive_type_from_mapper_class(resource_mapper),
        links: map_links,
        members: collection.map {|obj| resource_mapper.new(obj, policy).to_resource }
      )
    end

    def load_attribute(name)
      respond_to?(name) ? send(name) : collection.map(&name.to_sym)
    end

    def map_links
      links.map &send_with_args(:map_to_resource_link, self)
    end

  end
end
