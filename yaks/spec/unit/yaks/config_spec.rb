require 'spec_helper'

RSpec.describe Yaks::Config do
  include_context 'fixtures'

  def self.configure(&blk)
    subject(:config) { described_class.new(&blk) }
  end

  describe '#initialize' do
    context 'defaults' do
      configure {}

      its(:default_format) { should equal :hal }
      its(:policy_class)   { should < Yaks::DefaultPolicy }
      its(:primitivize)    { should be_a Yaks::Primitivize }
      its(:serializers)    { should eql(Yaks::Serializer.all)  }
      its(:serializers)    { should_not equal(Yaks::Serializer.all)  }
      its(:hooks)          { should eql([])  }

      it 'should have empty format options' do
        expect(config.format_options[:hal]).to eql({})
      end
    end

    context 'with a default format' do
      configure do
        default_format :json_api
      end

      its(:default_format) { should equal :json_api }
    end

    context 'with a custom policy class' do
      MyPolicy = Struct.new(:options)
      configure do
        policy MyPolicy
      end

      its(:policy_class) { should equal MyPolicy }
      its(:policy)       { should be_a  MyPolicy }
    end

    context 'with a rel template' do
      configure do
        rel_template 'http://rel/foo'
      end

      its(:policy_options) { should eql(rel_template: 'http://rel/foo') }
    end

    context 'with format options' do
      configure do
        format_options :hal, plural_links: [:self, :profile]
      end

      specify do
        expect(config.format_options[:hal]).to eql(plural_links: [:self, :profile])
      end
    end
  end

  describe '#call' do
    configure do
      rel_template 'http://api.mysuperfriends.com/{rel}'
      format_options :hal, plural_links: [:copyright]
      skip :serialize
    end

    specify do
      expect(config.call(john)).to eql(load_json_fixture 'john.hal')
    end
  end

end
