# encoding: utf-8

require 'spec_helper'
require 'yaks-sinatra'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class MediaType
  QUOTED_STRING = '[\w!#$%&\'()*+,-./:;<=>?@\[\]\\\\^`{|}~ \t\r\n]+'
  TOKEN = '[\w!\#$%&\'*+-.^`|~]+'
  TYPE_AND_SUBTYPE = "(?<maintype>#{TOKEN})/(?<subtype>#{TOKEN})"
  PARAMETER_VALUE = "(?:(?<value>#{TOKEN})|\"(?<q_value>#{QUOTED_STRING})\")"
  PARAMETER_RE = /\s*;\s*(?<name>#{TOKEN})\s*=\s*#{PARAMETER_VALUE}/m
  MEDIA_TYPE_RE = /^#{TYPE_AND_SUBTYPE}/

  def initialize(header_string)
    @header_string = header_string
  end

  def type_and_rest
    @type_and_rest ||= begin
      type_match = MEDIA_TYPE_RE.match(@header_string)
      return ["", ""] if type_match.nil?
      @main_type = type_match['maintype']
      @sub_type = type_match['subtype']
      type = type_match.to_s
      rest = @header_string[type.length..-1]
      [type, rest]
    end
  end

  def parameters
    @parameters ||= begin
      _, rest = type_and_rest
      parameters = {}
      rest.scan(PARAMETER_RE) do |name, value, q_value|
        parameters[name] = value || q_value
      end
      parameters
    end
  end

  def type
    @type ||= type_and_rest[0]
  end

  def main_type
    @main_type || type_and_rest && @main_type
  end

  def sub_type
    @sub_type || type_and_rest && @sub_type
  end

  def charset
    parameters['charset']
  end
end

module Yaks
  module Sinatra
    module Test
      module Helpers
        def make_req(mime_type = 'application/hal+json')
          header 'Accept', mime_type
          get '/'
        end

        def last_content_type
          MediaType.new(last_response.content_type)
        end
      end

      class ModularApp < ::Sinatra::Base
        module Helpers
          include Yaks::Sinatra::Test::Helpers

          def app
            Yaks::Sinatra::Test::ModularApp
          end
        end

        Root = Class.new(Struct.new(:name))

        class RootMapper < Yaks::Mapper
          link :self, '/'
        end

        register Yaks::Sinatra

        set :default_charset, 'utf-8'

        configure_yaks

        get '/' do
          yaks Root.new('root'), mapper: RootMapper
        end
      end

      module ClassicApp
        module Helpers
          include Yaks::Sinatra::Test::Helpers

          def app
            ::Sinatra::Application
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods, type: :integration
end
