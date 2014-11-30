module Yaks
  class Resource
    include Attributes.new(
              type: nil,
              rels: [],
              links: [],
              attributes: {},
              subresources: [],
              forms: []
            )

    def initialize(attrs = {})
      raise attrs.inspect if attrs.key?(:subresources) && !attrs[:subresources].instance_of?(Array)
      super
    end

    def [](attr)
      attributes[attr]
    end

    def find_form(name)
      forms.find { |form| form.name == name }
    end

    def seq
      [self]
    end

    def self_link
      links.reverse.find do |link|
        link.rel.equal? :self
      end
    end

    def collection?
      false
    end
    alias collection collection?

    def null_resource?
      false
    end

    def members
      raise UnsupportedOperationError, "Only Yaks::CollectionResource has members"
    end
    alias each members
    alias map members
    alias each_with_object members

    def update_attributes(new_attrs)
      update(attributes: @attributes.merge(new_attrs))
    end

    def add_rel(rel)
      append_to(:rels, rel)
    end

    def add_link(link)
      append_to(:links, link)
    end

    def add_form(form)
      append_to(:forms, form)
    end

    def add_subresource(subresource)
      append_to(:subresources, subresource)
    end

  end
end
