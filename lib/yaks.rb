# -*- coding: utf-8 -*-

require 'forwardable'
require 'set'

require 'concord'
require 'inflection'
require 'uri_template'

require 'yaks/util'
require 'yaks/fp'
require 'yaks/primitivize'

require 'yaks/default_policy'

module Yaks
  Undefined = Object.new

  YAKS_DEFAULT_OPTIONS = {
    singular_links: [:self, :profile]
  }

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

require 'yaks/mapper/link'
require 'yaks/mapper/association'
require 'yaks/mapper/has_one'
require 'yaks/mapper/has_many'
require 'yaks/mapper/config'
require 'yaks/mapper/class_methods'
require 'yaks/mapper'
require 'yaks/collection_mapper'

require 'yaks/serializer'
require 'yaks/hal_serializer'
require 'yaks/json_api_serializer'
require 'yaks/config'
