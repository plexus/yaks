require 'spec_helper'

module IntegrationRunner
  def run!
    specify do
      tests.each do |type, objects, result|
        expect(Yaks::Dumper.new(format: format).call(type, objects)).to eq result
      end
    end
  end
end

describe Yaks, 'integration tests' do
  include_context 'fixtures'

  context 'json api' do
    extend IntegrationRunner

    let(:format) { :json_api }
    let(:tests) do
      [
        ['friends', [john],
          {
            "friends" => [
              { "name"  => "john",
                "id"    => 1,
                "links" => {
                  'pets'      => [2, 3],
                  'pet_peeve' => [4]
                }
              }
            ],
            "linked" => {
              "pets" => [
                { "name"    => "boingboing",
                  "species" => "dog",
                  "id"      => 2
                },
                { "name"    => "wassup",
                  "species" => "cat",
                  "id"      => 3
                }
              ],
              "pet_peeve" => [
                { "id"   => 4,
                  "type" => "parsing with regexps"}
              ]
            }
          }
        ]
      ]
    end

    run!
  end

end
