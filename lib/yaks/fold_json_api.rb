# -*- coding: utf-8 -*-

module Yaks
  class FoldJsonApi
    include Concord.new(:collection)
    include Util
    extend Forwardable

    def_delegator :collection, :root_key

    def self.call(collection)
      new(collection).fold
    end

    def fold
      if collection.empty?
        {}
      else
        {
          root_key => collection.map(& μ(:fold_object) ),
          "linked" => fold_associated_objects
        }
      end
    end
    alias call fold

    private

    def fold_object(object)
      if object.has_associated_objects?
        object.attributes.merge Hash(links: link_ids(object))
      else
        object.attributes
      end
    end

    def link_ids(object)
      object.associations.reduce(Hash(), &μ(:fold_association_ids))
    end

    def fold_association_ids(hash, association)
      if association.one?
        hash.put(association.name, association.identities.first)
      else
        hash.put(association.name, association.identities)
      end
    end

    def fold_associated_objects
      association_names = Set(*
        collection.flat_map do |object|
          object.associations.map{|ass| [ass.name, ass.one?] }
        end
      )
      Hash(
        association_names.map do |name, one|
          objects = collection.flat_map(& σ(:associated_objects, name) )

          [ one ? pluralize(name.to_s) : name,
            Hamster.set(*objects).map(& μ(:fold_object) )
          ]
        end
      )
    end
  end
end
