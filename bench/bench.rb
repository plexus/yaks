
require 'benchmark/ips'
require 'yaks'

require_relative '../spec/acceptance/models'
require_relative '../spec/fixture_helpers'

Benchmark.ips do |x|
  $yaks = Yaks.new

  input = FixtureHelpers.load_yaml_fixture 'confucius'

  x.report "Simple HAL mapping" do
    $yaks.serialize(input)
  end

end
