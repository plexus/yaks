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
    include attributes.add(members: [], collection_rel: 'members')

    extend Forwardable
    def_delegators :members, :each

    # @return [Boolean]
    def collection?
      true
    end

  end
end
