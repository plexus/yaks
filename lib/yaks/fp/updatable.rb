module Yaks
  module FP

    class Updatable < Module
      def initialize(*attributes)
        define_method :update do |updates|
          self.class.new(
            *attributes.map {|attr| updates.fetch(attr) { send(attr) }}
          )
        end
      end
    end

  end
end
