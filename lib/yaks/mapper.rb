# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    extend ClassMethods, Forwardable
    include Util, CrossCutting

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
        map_attributes,
        map_links,
        map_subresources
      )
    end

    def map_links
      mapped = links.map &σ(:expand_with, μ(:load_attribute))
      mapped.cons(Resource::Link.new(:profile, profile_registry.find_by_type(profile_type), {}))
    end

    def profile_type
      config.profile || policy.derive_profile_from_mapper(self)
    end

    def map_attributes
      attributes.map &juxt(ι, μ(:load_attribute))
    end

    def map_subresources
      associations.map do |association|
        association.map_to_resource_pair(μ(:load_association))
      end
    end

    def load_attribute(name)
      respond_to?(name) ? send(name) : subject.send(name)
    end
    alias load_association load_attribute

    def profile
      config.profile || policy.derive_missing_profile_from_mapper(self)
    end

  end
end
