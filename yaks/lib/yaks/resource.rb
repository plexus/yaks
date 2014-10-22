module Yaks
  class Resource
    include Anima.new(:type, :links, :attributes, :subresources, :controls),
            Anima::Update,
            Enumerable

    attr_reader :type, :attributes, :links, :subresources

    def initialize(options = {})
      @type         = options.fetch(:type, nil)
      @attributes   = options.fetch(:attributes, {})
      @links        = options.fetch(:links, [])
      @subresources = options.fetch(:subresources, {})
    end

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

    def update_attributes(new_attrs)
      update(attributes: @attributes.merge(new_attrs))
    end

    def add_link(link)
      update(links: @links + [link])
    end

    def add_subresource(rel, subresource)
      update(subresources: @subresources.merge(rel => subresource))
    end
  end
end
