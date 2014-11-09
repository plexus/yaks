module Yaks
  class Resource
    include Attributes.new(
              type: nil,
              rels: [],
              links: [],
              attributes: {},
              subresources: [],
              controls: []
            )

    def initialize(attrs = {})
      raise attrs.inspect if attrs.key?(:subresources) && !attrs[:subresources].instance_of?(Array)
      super
    end

    def [](attr)
      attributes[attr]
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

    def add_control(control)
      append_to(:controls, control)
    end

    def add_subresource(subresource)
      append_to(:subresources, subresource)
    end

    def pp
      indent = ->(str) { str.lines.map {|l| "  #{l}"}.join }
      format = ->(val) { val.respond_to?(:pp) ? val.pp : val.inspect }

      fmt_attrs = self.class.attributes.attributes.map do |attr|
        value   = public_send(attr)
        fmt_val = case value
                  when Array
                    if value.inspect.length < 50
                      value.inspect
                    else
                      "[\n#{indent[value.map(&format).join(",\n")]}\n]"
                    end
                  else
                    format[value]
                  end
        "#{attr}=#{fmt_val}"
      end.join("\n")

      "#<#{self.class.name}\n#{indent[fmt_attrs]}\n>"
    end
  end
end
