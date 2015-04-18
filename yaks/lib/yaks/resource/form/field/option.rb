module Yaks
  class Resource
    class Form
      class Field
        class Option
          include Attribs.new(:value, :label, selected: false, disabled: false)
        end
      end
    end
  end
end
