# -*- coding: utf-8 -*-

module Yaks
  class Serializer
    include Util, Lookup
    extend ClassMethods

    attr_reader :serializer_lookup, :root_key, :object, :options

    def initialize(object, options = {})
      @object            = object
      @serializer_lookup = options.fetch(:serializer_lookup) { Yaks.default_serializer_lookup }
      @root_key          = options.fetch(:root_key) { self.class._root_key }
      @options           = options
    end

    def identity_key
      self.class._identity_key
    end

    def attributes
      self.class._attributes
    end

    def associations
      self.class._associations
    end

    # Methods that can be overridden in derived classed

    def filter(attributes)
      attributes
    end

    def load_attribute(name)
      send(name)
    end

    def load_association(name)
      send(name)
    end

    ###

    def resource
      Resource.new(
        serializable_attributes,
        serializable_associations
      )
    end

    def serializable_attributes
      Hash(filter(attributes).map {|attr| [attr, load_attribute(attr)] })
    end

    def serializable_associations
      filter(associations.map(&:name)).to_list.map do |association_name|
        association = associations.detect {|assoc| assoc.name == association_name }
        association.serializable_for( load_association(association.name), μ(:serializer_for) )
      end
    end
  end
end
