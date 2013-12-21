# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    extend ClassMethods, Forwardable
    include Util

    def_delegators 'self.class', :config
    def_delegators :config, :attributes, :links, :associations

    attr_reader :subject, :options
    private :subject, :options

    def initialize(subject, options = {})
      @subject = subject
      @options = YAKS_DEFAULT_OPTIONS.merge(options)
    end

    def to_resource
      Resource.new(
        nil,
        map_attributes,
        map_links,
        map_subresources
      )
    end

    def map_links
      mapped = links.map &σ(:expand_with, μ(:load_attribute))
      if config.profile
        mapped.cons(Resource::Link.new(:profile, profile_registry.find_uri(config.profile), {}))
      else
        mapped
      end
    end

    def map_attributes
      attributes.map &juxt(ι, μ(:load_attribute))
    end

    def map_subresources
      associations.map do |association|
        [ association.key, association.map_resource(load_association(association.name)) ]
      end
    end

    def load_attribute(name)
      respond_to?(name) ? send(name) : subject.send(name)
    end
    alias load_association load_attribute

    def policy
      options[:policy]
    end

    def profile_registry
      options[:profile_registry]
    end

    def profile
      config.profile || policy.derive_missing_profile_from_mapper(self)
    end

  end
end
