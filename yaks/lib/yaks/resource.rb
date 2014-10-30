module Yaks
  class Resource
    include Attributes.new(
              type: nil, links: [], attributes: {}, subresources: {}, controls: []
            ),
            Enumerable

    def [](attr)
      attributes[attr]
    end

    def each
      return to_enum unless block_given?
      yield self
    end

    def self_link
      links.reverse.find do |link|
        link.rel.equal? :self
      end
    end

    def collection?
      false
    end

    def null_resource?
      false
    end

    def collection_rel
      raise UnsupportedOperationError, "Only Yaks::CollectionResource has a collection_rel"
    end

    def members
      raise UnsupportedOperationError, "Only Yaks::CollectionResource has members"
    end

    def update_attributes(new_attrs)
      update(attributes: @attributes.merge(new_attrs))
    end

    def add_link(link)
      append_to(:links, link)
    end

    def add_control(control)
      append_to(:controls, control)
    end

    def add_subresource(rel, subresource)
      update(subresources: @subresources.merge(rel => subresource))
    end
  end
end
