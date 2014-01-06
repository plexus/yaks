require 'spec_helper'

describe Yaks::Mapper::MapLinks do
  let(:policy)           { Class.new(Yaks::DefaultPolicy) { def derive_profile_from_mapper(*); :the_profile ; end }.new }
  let(:mapper_class) do
    Class.new(Yaks::Mapper) do
      def get_title
        "The Title"
      end
    end
  end

  subject(:mapper) do
    mapper_class.new(Object.new, policy: policy)
  end

  context 'with a title proc' do
    before do
      mapper_class.link :the_link_rel, '/foo/bar', title: ->{ get_title }
    end

    it 'should resolve the title' do
      expect(mapper.map_links).to include Yaks::Resource::Link.new(:the_link_rel, '/foo/bar', title: 'The Title')
    end
  end

  context 'with a title string' do
    before do
      mapper_class.link :the_link_rel, '/foo/bar', title: 'fixed string'
    end

    it 'should resolve the title' do
      expect(mapper.map_links).to include Yaks::Resource::Link.new(:the_link_rel, '/foo/bar', title: 'fixed string')
    end
  end

  context 'with no title set' do
    before do
      mapper_class.link :the_link_rel, '/foo/bar'
    end

    it 'should resolve the title' do
      expect(mapper.map_links).to include Yaks::Resource::Link.new(:the_link_rel, '/foo/bar', {})
    end
  end
end
