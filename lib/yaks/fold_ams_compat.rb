# -*- coding: utf-8 -*-

module Yaks
  class FoldAmsCompat < FoldJsonApi
    include Util
    extend Forwardable

    def_delegator :collection, :root_key

    def fold
      Hamster.hash(
        root_key => collection.map(&method(:fold_object)),
      ).merge(
        fold_associated_objects
      )
    end
    alias call fold

    private

    def fold_object(object)
      object.attributes.merge(link_ids(object))
    end

    def fold_association_ids(hash, association)
      name = singular(association.name.to_s)
      if association.one?
        hash.put(name + '_id', association.identities.first)
      else
        hash.put(name + '_ids', association.identities)
      end
    end

  end
end
