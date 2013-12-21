# -*- coding: utf-8 -*-
module Yaks
  # oRFC6906 The "profile" link relation http://tools.ietf.org/search/rfc6906
  class ProfileRegistry
    class << self
      include Util

      def create(&blk)
        blk ||= ->{}
        Class.new(self).tap(&σ(:instance_eval, &blk)).new
      end

      def profile(type, uri)
        profiles {|reg| reg.put(type, uri)}
      end

      def profiles
        @profiles ||= Yaks::Hash()
        @profiles = yield(@profiles) if block_given?
        @profiles
      end

      def inherited(child)
        child.profiles { @profiles }
      end
    end

    def find_uri(type)
      self.class.profiles[type]
    end

    def find_type(by_uri)
      self.class.profiles.detect {|type, uri| uri == by_uri}.first
    end
  end

  class NullProfileRegistry
    def find_uri(type)
      type
    end
    alias find_type find_uri
  end
end
