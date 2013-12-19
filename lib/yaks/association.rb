module Yaks
  class Association
    include Concord.new(:name, :has_one, :options)
    include Util

    public :name

    def serializable_for(resource, serializer_lookup)
      if has_one
        objects = resource.nil? ? List() : List(serializer_lookup.(resource).resource)
      else
        objects = resource.to_list.map do |obj|
          serializer_lookup.(obj).resource
        end
      end
      SerializableAssociation.new( ResourceCollection.new(name, :id, objects), has_one, options )
    end
  end
end
