module Yaks
  module Serializer
    def self.register(format, serializer)
      raise "Serializer for #{format} already registered" if all.key? format
      all[format] = serializer
    end

    def self.all
      @serializers ||= {json: JSONWriter}
    end

    module JSONWriter
      extend Yaks::FP::Callable

      def self.call(data, env)
        JSON.pretty_generate(data)
      end

      def self.transitive?
        true
      end

      def self.inverse
        JSONReader
      end
    end

    module JSONReader
      extend Yaks::FP::Callable

      def self.call(data, env)
        JSON.parse(data)
      end

      def self.transitive?
        true
      end

      def self.inverse
        JSONWriter
      end
    end

  end
end
