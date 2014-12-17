module Yaks
  class Resource
    class Form
      class Fieldset
        include Attributes.new(:fields)

        def type
          :fieldset
        end
      end
    end
  end
end
