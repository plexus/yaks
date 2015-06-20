module Yaks
  class MutableResource < Resource

    def merge_attributes(new_attrs)
      @attributes.merge!(new_attrs)
      self
    end

    def add_rel(rel)
      @rels << rel
    end

    def add_link(link)
      @links << link
    end

    def add_form(form)
      @forms << form
    end

    def add_subresource(subresource)
      @subresources << subresource
    end

  end
end
