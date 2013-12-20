require 'pathname'

ROOT = Pathname(__FILE__).join('../..')

$LOAD_PATH.unshift(ROOT.join('lib'))

require 'yaks'
require 'virtus'

require_relative 'support/models'
require_relative 'support/pet_peeve_mapper'
require_relative 'support/friends_mapper'
require_relative 'support/fixtures'
