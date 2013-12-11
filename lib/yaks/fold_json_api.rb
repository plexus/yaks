module Yaks
  class FoldJsonApi
    include Concord.new(:collection)
    include Util
    extend Forwardable

    def_delegator :collection, :root_key

    def fold
      Hamster.hash(
        root_key => collection.map(&method(:fold_object)),
        "linked" => fold_associated_objects
      )
    end

    private

    def fold_object(object)
      if object.has_associated_objects?
        object.attributes.merge(Hamster.hash(links: link_ids(object)))
      else
        object.attributes
      end
    end

    def link_ids(object)
      object.associations.reduce(
        Hamster.hash,
        &method(:fold_association_ids)
      )
    end

    def fold_association_ids(hash, association)
      if association.one?
        hash.put(association.name, association.identities.first)
      else
        hash.put(association.name, association.identities)
      end
    end

    def fold_associated_objects
      association_names = Hamster.set(*
        collection.flat_map do |object|
          object.associations.map{|ass| [ass.name, ass.one?] }
        end
      )
      Hamster.hash(
        association_names.map do |name, one|
          [
            one ? pluralize(name.to_s) : name,
            Hamster.set(*
              collection.flat_map do |object|
                object.associated_objects(name)
              end
            ).map(&method(:fold_object))
          ]
        end
      )
    end
  end
end
