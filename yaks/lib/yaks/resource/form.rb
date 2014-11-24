module Yaks
  class Resource
    class Form
      include Yaks::Mapper::Form.attributes

      class Field
        include Yaks::Mapper::Form::Field.attributes
      end
    end
  end
end
