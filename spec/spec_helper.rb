require 'pathname'

ROOT = Pathname(__FILE__).join('../..')

$LOAD_PATH.unshift(ROOT.join('lib'))

require 'yaks'
require 'virtus'

require_relative 'support/models'
require_relative 'support/serializers'
require_relative 'support/fixtures'
