module PlexusSerializers
  class SerializableObject
    include Concord.new(:attributes, :associations)
    extend Forwardable

    public :attributes, :associations

    def_delegator :attributes, :[]

    def associated_objects(association_name)
      associations.detect {|association| association_name = association.name }.objects
    end

    def has_associated_objects?
      !associations.all?(&:empty?)
    end
  end
end
