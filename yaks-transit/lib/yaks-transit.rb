require 'yaks'
require 'transit'

Yaks::Serializer.register(:transit, ->(i, _env = {}) {i})

module Yaks
  class Format
    class Transit < self
      register :transit, :transit, 'application/transit+json'

      class WriteHandler
        def initialize(klass)
          @klass = klass
        end

        def tag(_o)
          Util.underscore(@klass.name.gsub(/.*::/, ''))
        end

        def rep(_o)
        end

        def string_rep(_)
          nil
        end
      end

      class ReadHandler
        def initialize(klass)
          @klass = klass
        end

        def from_rep(rep)
          @klass.new(rep)
        end
      end

      HANDLERS = {
        Resource              => WriteHandler.new(Resource),
        Resource::Link        => WriteHandler.new(Resource::Link),
        Resource::Form        => WriteHandler.new(Resource::Form),
        Resource::Form::Field => WriteHandler.new(Resource::Form::Field)
      }

      def call(resource, _env = {})
        StringIO.new.tap do |io|
          ::Transit::Writer.new(:json, io, handlers: HANDLERS).write(resource)
        end.string
      end
    end
  end
end
