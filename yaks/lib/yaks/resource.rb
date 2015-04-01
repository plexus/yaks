module Yaks
  class Resource
    include Attribs.new(
              type: nil,
              rels: [],
              links: [],
              attributes: {},
              subresources: [],
              forms: []
            )
    extend Util::Deprecated

    def initialize(attrs = {})
      raise attrs.inspect if attrs.key?(:subresources) && !attrs[:subresources].instance_of?(Array)
      super
    end

    def [](attr)
      attributes[attr]
    end

    def find_form(name)
      forms.find { |form| form.name.equal? name }
    end

    def seq
      [self]
    end

    def self_link
      # This reverse is there so that the last :self link specified
      # "wins". The use case is having a self link defined in a base
      # mapper class, but having it overridden in specific
      # subclasses. In combination with formats that expect resources
      # to have up to one self link, this is the preferred behavior.
      # However since 0.7.5 links take a "replace: true" option to
      # specifiy they should replace previous defintions with the same
      # rel, wich should be used instead. The behavior that the last
      # link "wins" will be deprecated, the result of multiple links
      # with the same rel will be unspecified.
      links.reverse.find do |link|
        link.rel.equal? :self
      end
    end

    def collection?
      false
    end
    alias collection collection?

    def with_collection(*)
      self
    end

    def null_resource?
      false
    end

    def members
      raise UnsupportedOperationError, "Only Yaks::CollectionResource has members"
    end
    alias each members
    alias map members
    alias each_with_object members
    alias with_members members

    def merge_attributes(new_attrs)
      with(attributes: @attributes.merge(new_attrs))
    end
    deprecated_alias :update_attributes, :merge_attributes

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
