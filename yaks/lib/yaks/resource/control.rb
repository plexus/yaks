module Yaks
  class Resource
    class Control
      include Attributes.new(:name, :href, :title, :media_type, :fields, method: 'GET')
    end
  end
end
