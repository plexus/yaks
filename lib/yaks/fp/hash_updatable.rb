module Yaks
  module FP

    class HashUpdatable < Module
      def initialize(*attributes)
        define_method :update do |updates|
          self.class.new(
            attributes.each_with_object({}) {|attr, hsh|
              hsh[attr] = updates.fetch(attr) { send(attr) }
            }
          )
        end
      end
    end

  end
end
