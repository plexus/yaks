module Yaks
  # A collection of Resource objects, it has members, and its own set of link
  # relations like self and profile describing the collection.
  #
  # A collection can be the top-level result of an API call, like all posts to
  # a blog, or a subresource collection, like the comments on a post result.
  #
  class CollectionResource < Resource
    include attributes.add(members: [])

    extend Forwardable
    def_delegators :members, :each, :map, :each_with_object

    # @return [Boolean]
    def collection?
      true
    end

    def seq
      self
    end
  end
end
