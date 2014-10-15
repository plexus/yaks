module Yaks
  # A collection of Resource objects, it has members, and its own set of link
  # relations like self and profile describing the collection.
  #
  # A collection can be the top-level result of an API call, like all posts to
  # a blog, or a subresource collection, like the comments on a post result.
  #
  # Some formats treat everything like a collection, and a single resource as a
  # collection of one. Others treat every top level response as singular, e.g.
  # a single "collection of orders". Because of this Resource and
  # CollectionResource can both be iterated with #each, for the "everything is
  # a collection crowd", and they both respond to `links`, `attributes` and
  # `subresources`, so they can both be approached like a singular resource.
  #
  # In the second case a collection has a single "subresource", being its
  # members.
  class CollectionResource < Resource
    include Equalizer.new(:type, :links, :attributes, :members, :collection_rel)
    include FP::HashUpdatable.new(:type, :links, :attributes, :members, :collection_rel)
    include Enumerable

    extend Forwardable

    # @!attribute [r] type
    #   @return [String]
    # @!attribute [r] links
    #   @return [Array]
    # @!attribute [r] members
    #   @return [Array]
    # @!attribute [r] collection_rel
    #   @return [String]
    attr_reader :type, :links, :members, :collection_rel

    def_delegators :members, :each

    # @param [Hash] options
    # @return [CollectionResource]
    def initialize(options)
      super
      @members     = options.fetch(:members, [])
      @collection_rel = options.fetch(:collection_rel, 'members')
    end

    # Make a CollectionResource quack like a resource.
    #
    # At the moment this is only for HAL, which always assumes
    # a singular resource at the top level, this way it can treat
    # whatever it gets as a single resource with links and subresources,
    # we just push the collection down one level.
    #
    # Once inside subresources the HAL format does check if a resource
    # is a collection, since there it does make a distinction, and because
    # in that case it will iterate with each/map rather than calling subresources,
    # this doesn't cause infinite recursion. Not very pretty, needs looking at.
    #
    # :(
    #
    # @return [Hash]
    def subresources
      if any?
        { collection_rel => self }
      else
        {}
      end
    end

    # @return [Boolean]
    def collection?
      true
    end

  end
end
