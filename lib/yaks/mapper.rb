# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    extend ClassMethods, Forwardable
    include Util, MapLinks, SharedOptions

    def_delegators 'self.class', :config
    def_delegators :config, :attributes, :links, :associations

    attr_reader :subject, :options
    private :subject, :options
    alias object subject

    def initialize(subject, options = {})
      @subject = subject
      @options = YAKS_DEFAULT_OPTIONS.merge(options)
    end

    def to_resource
      return NullResource.new if subject.nil?

      Resource.new(
        map_attributes,
        map_links,
        map_subresources
      )
    end

    def profile_type
      config.profile || policy.derive_profile_from_mapper(self)
    end

    def map_attributes
      filter(attributes).map &juxt(identity_function, method(:load_attribute))
    end

    def map_subresources
      filtered = filter(associations.map(&:name))
      associations.select{|assoc| filtered.include? assoc.name}.map do |association|
        association.map_to_resource_pair(profile_type, method(:load_association), options)
      end
    end

    def load_attribute(name)
      respond_to?(name) ? send(name) : subject.send(name)
    end
    alias load_association load_attribute

    def profile
      config.profile || policy.derive_missing_profile_from_mapper(self)
    end

    def filter(attrs)
      attrs
    end

  end
end
