module Yaks
  class RelRegistry
  end

  class TemplateRelRegistry < RelRegistry
    def initialize(template)
      @template = URITemplate.new(template)
    end

    def lookup(source, destination)
      @template.expand(:src => source, :dest => destination)
    end
  end

  class NullRelRegistry < TemplateRelRegistry
    def initialize
      super('rel:src={src}&dest={dest}')
    end
  end
end
