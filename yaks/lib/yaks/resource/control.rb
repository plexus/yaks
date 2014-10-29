module Yaks
  class Resource
    class Control
      include Yaks::Mapper::Control.attributes

      class Field
        include Yaks::Mapper::Control::Field.attributes
      end
    end
  end
end
