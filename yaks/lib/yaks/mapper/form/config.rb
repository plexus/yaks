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
                  fields: [],
                  dynamic_blocks: []
                )

        def dynamic(&blk)
          append_to(:dynamic_blocks, blk)
        end
      end
    end
  end
end
