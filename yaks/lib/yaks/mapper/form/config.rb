module Yaks
  class Mapper
    class Form
      class Config
        include Attributes.new(
                  name: nil,
                  action: nil,
                  title: nil,
                  method: nil,
                  media_type: nil,
                  fields: []
                )
      end
    end
  end
end
