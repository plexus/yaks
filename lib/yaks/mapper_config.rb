module Yaks
  class MapperConfig
    include Equalizer.new(:attributes)

    def initialize(attributes = Hamster.list)
      @attributes = attributes
      freeze
    end

    def new(updates)
      self.class.new(
        updates.fetch(:attributes) { attributes }
      )
    end

    def attributes(*attrs)
      return @attributes if attrs.empty?
      new(
        attributes: @attributes + attrs.to_list
      )
    end
  end
end
