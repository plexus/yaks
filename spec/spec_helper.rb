require 'pathname'

ROOT = Pathname(__FILE__).join('../..')

$LOAD_PATH.unshift(ROOT.join('lib'))

require 'plexus_serializers'
require 'virtus'
