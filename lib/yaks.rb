# -*- coding: utf-8 -*-

require 'forwardable'
require 'set'
require 'pathname'

require 'concord'
require 'inflection'
require 'uri_template'
require 'rack/accept'

require 'yaks/util'
require 'yaks/fp'
require 'yaks/fp/updatable'
require 'yaks/fp/hash_updatable'
require 'yaks/primitivize'

require 'yaks/default_policy'

module Yaks
  Undefined = Object.new
  Root = Pathname(__FILE__).join('../..')

  class << self
    def new(&blk)
      Yaks::Config.new(&blk)
    end
  end

end


require 'yaks/resource'
require 'yaks/null_resource'
require 'yaks/resource/link'
require 'yaks/collection_resource'

require 'yaks/mapper/attribute'
require 'yaks/mapper/link'
require 'yaks/mapper/association'
require 'yaks/mapper/has_one'
require 'yaks/mapper/has_many'
require 'yaks/mapper/config'
require 'yaks/mapper/class_methods'
require 'yaks/mapper'
require 'yaks/collection_mapper'

require 'yaks/serializer'
require 'yaks/serializer/hal'
require 'yaks/serializer/json_api'
require 'yaks/serializer/collection_json'

require 'yaks/config/dsl'
require 'yaks/config'
