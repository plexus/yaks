module Yaks
  module Serializer
    def self.register(format, serializer)
      raise "Serializer for #{format} already registered" if all.key? format
      all[format] = serializer
    end

    def self.all
      @serializers ||= {}
    end

    register :json, JSON.method(:pretty_generate)
  end
end
